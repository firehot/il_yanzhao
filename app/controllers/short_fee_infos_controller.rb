#coding: utf-8
class ShortFeeInfosController < BaseController
  table :bill_date,:org,:note
  def create
    bill = resource_class.new(params[resource_class.model_name.underscore])
    get_resource_ivar || set_resource_ivar(bill)
    bill.carrying_bill_ids  = params[:bill_ids]  unless params[:bill_ids].blank?
    bill.write_off
    create!
  end
  #GET search
  #显示查询窗口
  def search
    render :partial => "search"
  end
  #需要重写collection方法
  protected
  def collection
    @search = end_of_association_chain.where(["short_fee_infos.org_id = ? or short_fee_infos.op_org_id =?",current_user.default_org.id,current_user.default_org.id]).search(params[:search])
    get_collection_ivar || set_collection_ivar(@search.select("DISTINCT #{resource_class.table_name}.*").order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]))
  end


end
