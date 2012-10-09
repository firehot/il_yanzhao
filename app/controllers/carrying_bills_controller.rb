# -*- encoding : utf-8 -*-
#运单controller基础类
require 'iconv'
class CarryingBillsController < BaseController
  #查询服务,去除layout
  layout false,:only => [:search_service_page,:search_service]
  skip_before_filter :authenticate_user!,:only => [:search_service_page,:search_service]
  skip_authorize_resource :only => [:search_service_page,:search_service]
  #http_cache :new,:last_modified => Proc.new {|c| c.send(:last_modified)},:etag => Proc.new {|c| c.send(:etag,"carrying_bill_new")}
  #判断是否超过录单时间,超过录单时间后,不可再录入票据
  before_filter :check_expire,:only => :new
  before_filter :pre_process_search_params,:only => [:index,:rpt_turnover,:turnover_chart]
  belongs_to :load_list,:distribution_list,:deliver_info,:settlement,:refound,:cash_payment_list,:transfer_payment_list,:cash_pay_info,:transfer_pay_info,:post_info,:transit_info,:transit_deliver_info,:polymorphic => true,:optional => true

  #覆盖默认的index方法,主要是为了导出
  def index
    super do |format|
      format.csv {send_data resource_class.to_csv(@search)}
    end
  end
  #导出查询结果为excel
  #GET carrying_bills/export_excel
  def export_excel
    @search = end_of_association_chain.accessible_by(current_ability,:read_with_conditions).search(params[:search]).order(sort_column + ' ' + sort_direction)
    xls = render_to_string(:partial => "shared/carrying_bills/excel",:layout => false)
    send_data show_or_hide_fields_for_export(xls),:filename => "bill.xls"
  end

  #导出短信群发文本
  #GET carrying_bills/export_sms_txt.txt
  def export_sms_txt
    respond_to do |format|
      format.text do
        #FIXME 垃圾短信公司,客户端软件不支持utf-8格式的导出文件,只能进行转换
        send_txt = Iconv.conv("gb2312//IGNORE","utf-8",resource_class.export_sms_txt_for_arrive(params[:bill_ids]))
        send_data send_txt,:type => "text/plain;charset=gb2312;header=present",:filename => 'sms.txt'
      end
    end
  end
  #GET search
  #显示查询窗口
  def search
    respond_to do |format|
      format.html
      format.js  {render :partial => "shared/carrying_bills/search"}
    end
  end
  def show
    super do |format|
      format.js {render :partial => "shared/carrying_bills/show",:locals => {:show => resource }}
    end
  end
  #简单查询,用于报表统计
  def simple_search
    @search = resource_class.search(params[:search])
  end
  #简单查询,按照录入时间
  def simple_search_with_created_at
    @search = resource_class.search(params[:search])
  end
  #重写destroy方法
  def destroy
    bill = get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
    bill.destroy
    flash[:notice] = "运单已删除."
    redirect_to :root
  end
  #重写修改方法
  def update
    bill = get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
    original_bill = bill.clone  #保存原始运单信息
    bill.attributes=params[resource_class.model_name.underscore.to_sym]
    logger.debug "original_carrying_fee = #{bill.original_carrying_fee}"
    logger.debug "carrying_fee = #{bill.carrying_fee}"
    authorize! :update_goods_fee,bill,:message => "你无权修改货款!" if can? :update_goods_fee,original_bill
    logger.debug "pass update_goods_fee authorize"
    if can? :update_all,original_bill
      authorize! :update_all,bill,:message => "你无权修改该票据!"
      logger.debug "pass update_goods_fee authorize"

    elsif can? :update_carrying_fee_100,original_bill
      authorize! :update_carrying_fee_100,bill,:message => "你减免运费金额超过100%!"

      logger.debug "pass update_carrying_fee_100 authorize"
    elsif can? :update_carrying_fee_50,original_bill
      authorize! :update_carrying_fee_50,bill,:message => "你运费金额超过50%!"

      logger.debug "pass update_carrying_fee_50 authorize"
    elsif can? :update_carrying_fee_20,original_bill
      authorize! :update_carrying_fee_20, bill,:message => "你减免运费金额超过20%!"
      logger.debug "pass update_carrying_fee_20 authorize"
    end
    update!
  end

  #PUT /carrying_bills/1/reset
  def reset
    bill = get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
    bill.reset
    flash[:success] = "运单已成功重置."
    redirect_to bill
  end
  #运单作废
  #PUT /carrying_bills/1/invalidate
  def invalidate
    bill = get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
    bill.invalidate
    flash[:success] = "运单已被作废."
    redirect_to bill
  end
  #运单注销
  #PUT /carrying_bills/:id/cancel
  def cancel
    bill = get_resource_ivar || set_resource_ivar(resource_class.find(params[:id]))
    bill.note += params[:cancel_note] if params[:cancel_note].present?
    bill.cancel
    flash[:success] = "运单已被注销."
    redirect_to bill
  end

  #日/月营业额统计
  def rpt_turnover
    @search = resource_class.where(:from_org_id => current_user.current_ability_org_ids).turnover.search(params[:search])
    @carrying_bills = @search.all
    #get_collection_ivar || set_collection_ivar(@search.all)
  end
  #营业额统计柱状图
  def turnover_chart
    @search = resource_class.where(:from_org_id =>current_user.current_ability_org_ids).turnover.search(params[:search])
    @carrying_bills = @search.all
  end
  #货款出入情况
  def sum_goods_fee_inout
    @sum_goods_fee_in = resource_class.sum_goods_fee_in(current_user.current_ability_org_ids,params[:date_from] || Date.today.beginning_of_month,params[:date_to] || Date.today.end_of_month)
    @sum_goods_fee_out = resource_class.sum_goods_fee_out(current_user.current_ability_org_ids,params[:date_from] || Date.today.beginning_of_month,params[:date_to] || Date.today.end_of_month)
  end
  #外部查询服务界面
  def search_serviece_page ; end
  def search_service
    if params[:bill_nos].blank?
      render :action => :search_service_page
    else
      bill_nos = params[:bill_nos].split(',')
      @carrying_bills = CarryingBill.where(:bill_no => bill_nos)
    end
  end
  #显示多运单查询界面
  #GET carrying_bills/multi_bills_search
  def multi_bills_search ; end
  #显示按照客户编号查询运单界面
  #GET /carrying_bills/customer_code_search
  def customer_code_search ; end

  private
  def check_expire
    if current_user.default_org.input_expire?
      flash[:error]="录单时间截至到#{current_user.default_org.lock_input_time},已过录单时间."
      redirect_to :back
    end
  end
  protected
  def collection
    @search = end_of_association_chain.accessible_by(current_ability,:read_with_conditions).search(params[:search])
    set_collection_ivar(@search.select("DISTINCT #{resource_class.table_name}.*").with_association.order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]))
  end
end
