#coding: utf-8
class Ability
  include CanCan::Ability
  def initialize(user)
    set_alias_actions
    set_user_powers(user)
    set_bill_update_permission(user)
  end
  private
  def set_alias_actions
    #可以查看,就可以查询
    alias_action :search,:to => :read

    #导出到excel，从export映射到export_excel
    alias_action :export_excel,:to => :export
    #未提货报表
    alias_action :simple_search,:to => :rpt_no_delivery
    #本地未提货报表
    alias_action :simple_search,:to => :local_rpt_no_delivery
    #始发地收货统计
    alias_action :read,:to => :rpt_to_me
    #提货未提款统计
    alias_action :simple_search,:to => :rpt_no_pay
    #日营业额统计
    alias_action :rpt_turnover,:to => :rpt_daily_income
    #月营业额统计
    alias_action :rpt_turnover,:to => :rpt_mth_income
    #退货未发票据统计
    alias_action :simple_search,:to => :rpt_return_no_ship

    alias_action :read,:to => :simple_search
    alias_action :read,:to => :export_excel
    alias_action :read,:to => :rpt_turnover
    alias_action :read,:to => :turnover_chart
    #代收货款收入/支出统计
    alias_action :read,:to => :sum_goods_fee_inout
    #before_new是新建退货单的初始页面
    alias_action :before_new,:to => :create

    alias_action :read,:to => :process_handle #发车
    alias_action :process_handle,:to => :ship  #发车
    alias_action :process_handle,:to => :reach #到货确认
    alias_action :process_handle,:to => :refound_confirm #收款清单确认
    #结算员交款清单-交款确认
    alias_action :process_handle,:to => :settlement_confirm
    #代收货款支付清单(转账)转账确认
    alias_action :process_handle,:to => :transfer  #转账确认
    #user 重设置usb key
    alias_action :read,:update => :reset_usb_pin #重设usb pin
    #结算员交款清单-中转交款确认
    alias_action :read,:to => :direct_refunded_confirmed
    #批量提货
    alias_action :read,:create,:to => :batch_deliver #批量提货
    alias_action :read,:create,:to => :print_deliver #打印提货

    #理赔
    alias_action :read,:update,:to => :show_authorize #授权核销
    alias_action :read,:update,:to => :show_claim
    alias_action :read,:update,:to => :show_identify
    #理赔信息,核销前可修改
    alias_action :read,:update,:to => :update_with_submited

    #运费及货款修改
    alias_action :read,:update,:to => :update_carrying_fee_20
    alias_action :read,:update,:to => :update_carrying_fee_50
    alias_action :read,:update,:to => :update_carrying_fee_100
    alias_action :read,:update,:to => :update_goods_fee
    alias_action :read,:update,:to => :update_all
    #修改录单限制时间
    alias_action :read,:update,:to => :only_edit_lock_time


    #设置默认权限,可以修改/新建/删除,就具备查看权限
    alias_action :read ,:to => :create
    alias_action :read ,:to => :update
    alias_action :read ,:to => :destroy
    alias_action :read ,:to => :reset
    #可打印运单,就具备运单打印计数功能
    alias_action :read ,:print_counter,:to => :print
    alias_action :read ,:to => :invalidate #运单作废
  end
  #设置当前用户权限
  def set_user_powers(user)
    #设置read条件
    SystemFunctionOperate.all.each do |sfo|
      f_obj = sfo.function_obj
      the_model_class = f_obj[:subject].constantize
      conditions = f_obj[:conditions]
      if f_obj[:action].eql?(:read)
        if conditions.present?
          can :read_with_conditions,the_model_class ,eval(f_obj[:conditions])
        else
          can :read_with_conditions,the_model_class
        end
      end
    end

    if user.is_admin?
      SystemFunctionOperate.all.each do |sfo|
        f_obj = sfo.function_obj
        the_model_class = f_obj[:subject].constantize
        if f_obj[:conditions].present?
          can f_obj[:action],the_model_class ,eval(f_obj[:conditions])
        else
          can f_obj[:action],the_model_class
        end
      end
    else
      user.default_role.selected_sfos.each do |sfo|
        f_obj = sfo.function_obj
        the_model_class = f_obj[:subject].constantize
        if f_obj[:conditions].present?
          can f_obj[:action],the_model_class ,eval(f_obj[:conditions])
        else
          can f_obj[:action],the_model_class
        end
      end
    end
    #设定用户对运单的操作权限
    ability_org_ids = user.current_ability_org_ids
    #定义运单的读权限,设定alias_action时,conditions 会丢失
    #read_with_conditoins 只在accessible_by中使用
    can :read_with_conditions,CarryingBill,['carrying_bills.from_org_id in (?) or carrying_bills.transit_org_id in (?)  or carrying_bills.to_org_id in (?)',ability_org_ids,ability_org_ids,ability_org_ids] do |bill|
      ability_org_ids.include?(bill.from_org_id) or ability_org_ids.include?(bill.to_org_id) or ability_org_ids.include?(bill.transit_org_id)
    end
    can :read,CarryingBill
    can :export_excel,CarryingBill
    #默认可查询运费
    can :simple_search,CarryingBill
    #录入票据时,默认可读取转账客户信息
    can :read,Vip
    can :read_with_conditions,Vip

    #登录时,可操作current_role_change action
    can :current_role_change,Role
    #登录后,可修改自身密码
    can :edit_password,User
    #可更新自身密码
    can :update_password,User
    #可查看imported_customer，就可查看customer_fee_info
    can :read,CustomerFeeInfo if can? :read,ImportedCustomer
    #可创建实际装车清单
    can :create,ActLoadList if can? :build_act_load_list,LoadList
  end
  #定义运单修改权限
  def set_bill_update_permission(user)
    ability_org_ids = user.current_ability_org_ids
    #可修改20%运费
    if can? :update_carrying_fee_20,CarryingBill
      #重新设置运单不可修改
      cannot :update_carrying_fee_20,CarryingBill
      can :update_carrying_fee_20,CarryingBill do |bill|
        (bill.original_carrying_fee > 0) ? ((bill.original_carrying_fee - bill.carrying_fee)/bill.original_carrying_fee <= 0.2 and ability_org_ids.include?(bill.from_org_id) and ['billed','loaded','shipped','reached','distributed'].include?(bill.state)) : true
      end
    end
    #可修改50%运费
    if can? :update_carrying_fee_50,CarryingBill
      cannot :update_carrying_fee_50,CarryingBill
      can :update_carrying_fee_50,CarryingBill do |bill|
        (bill.original_carrying_fee > 0) ? ((bill.original_carrying_fee - bill.carrying_fee)/bill.original_carrying_fee <= 0.5 and ability_org_ids.include?(bill.from_org_id) and ['billed','loaded','shipped','reached','distributed'].include?(bill.state)) : true
      end
    end
    #可修改100%运费
    if can? :update_carrying_fee_100,CarryingBill
      cannot :update_carrying_fee_100,CarryingBill
      can :update_carrying_fee_100,CarryingBill do |bill|
        ability_org_ids.include?(bill.from_org_id) and ['billed','loaded','shipped','reached','distributed'].include?(bill.state)
      end
    end
  end
end
