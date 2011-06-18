#coding: utf-8
class GoodsExceptionsController < BaseController
  table :bill_date,:org,:carrying_bill,:except_des,:except_num,:human_state_name,:note,:user
  #需要跳过对update的权限检查,在进行核销/理赔/责任鉴定时候,使用了update
  skip_authorize_resource :only => :update
  def create
    bill = resource_class.new(params[resource_class.model_name.underscore])
    get_resource_ivar || set_resource_ivar(bill)
    bill.carrying_bill_id  = params[:bill_ids].first  unless params[:bill_ids].blank?
    create!
  end
  def update
    bill = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(bill)
    update!
    bill.process if bill.valid?
  end

  #GET /goods_exceptions/1/show_authorize
  #显示授权核销界面
  def show_authorize
    goods_exception = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(goods_exception)
    goods_exception.build_gexception_authorize_info
  end
  #GET /goods_exceptions/1/show_claim
  #显示理赔界面
  def show_claim
    goods_exception = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(goods_exception)
    goods_exception.build_claim
  end
  #GET /goods_exceptions/1/show_identify
  #显示责任鉴定界面
  def show_identify
    goods_exception = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(goods_exception)
    goods_exception.build_goods_exception_identify
  end
  #显示查询窗口
  def search
    render :partial => "search"
  end
  #需要重写collection方法
  protected
  def collection
    @search = end_of_association_chain.where(["goods_exceptions.org_id in (?) or goods_exceptions.op_org_id in (?)",current_user.current_ability_org_ids,current_user.current_ability_org_ids]).search(params[:search])
    get_collection_ivar || set_collection_ivar(@search.select("DISTINCT #{resource_class.table_name}.*").order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]))
  end
end
