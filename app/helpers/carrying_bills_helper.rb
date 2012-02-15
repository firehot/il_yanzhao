# -*- encoding : utf-8 -*-
#coding: utf-8
module CarryingBillsHelper
  #运费支付方式显示
  def pay_type_des(pay_type)
    pay_type_des = ""
    CarryingBill.pay_types.each {|des,code| pay_type_des = des if code == pay_type }
    pay_type_des
  end
  #票据状态
  def states_for_select
    CarryingBill.state_machine.states.collect{|state| [state.human_name,state.value] }
  end
  #短途运费状态
  def short_fee_states_for_select
    CarryingBill.state_machines[:from_short_fee_state].states.collect{|state| [state.human_name,state.value] }
  end

  #得到查询对象的id数组
  def search_ids
    @search.select("carrying_bills.id,carrying_bills.from_org_id").map {|bill| bill.id }.to_json
  end
  #得到票据合计信息
  def search_sum
    sum_info = CarryingBill.search_sum(@search)
    sum_info
  end
  #得到滞留天数对应的class
  #4天之内为白色，5—8天为兰色，9—12天为绿色，13—16天为黄色，17—20天为红色，21天后全部为黑色。
  def stranded_class(days)
    ret_class=''
    ret_class="white-bill" if days <= 4
    ret_class="blue-bill" if days >= 4 and days <= 8
    ret_class="green-bill" if days >= 9 and days <= 12
    ret_class="yellow-bill" if days >= 13 and days <= 16
    ret_class="red-bill" if days >= 17 and days <= 20
    ret_class="black-bill" if days >= 21
    ret_class
  end
  #生成show_fields/hide_fields css selector
  def gen_fields_selector(fields_selector="",show=true)
    css_array=[]
    css_array << (show ? params[:show_fields] : params[:hide_fields]) << fields_selector
      css_array.delete_if {|x| x.blank?}
    css_array.join(",")
  end
  #设置运单修改权限
  def get_bill_update_class(resource)
    can_update =[]
    if can?(:update_all,resource)
      can_update << 'update_all'
    else
      can_update <<  'update_carrying_fee' if can?(:update_carrying_fee_20,resource) or can?(:update_carrying_fee_50,resource) or can?(:update_carrying_fee_100,resource)
      can_update << 'update_goods_fee' if can?(:update_goods_fee,resource)
    end
    can_update=[] if resource.new_record?
    #得到是否可修改运单日期
    #可修改运单日期:返回edit_bill_date
    can_update << 'edit_bill_date' if can?(:edit_bill_date,resource)

    can_update.join(' ')
  end
  #打印次数
  def print_counter_for_select
    [["打印多次",2]]
  end
end

