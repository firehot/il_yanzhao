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

end
