class GoodsErrorsController < BaseController
  table :bill_date,:org,:except_des,:except_num,:note,:user,:human_state_name
  #需要跳过对update的权限检查,在进行核销/理赔/责任鉴定时候,使用了update
  skip_authorize_resource :only => :update
  def update
    bill = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(bill)
    update!
    bill.process if bill.valid?
  end

  #GET /goods_exceptions/1/show_authorize
  #显示授权核销界面
  def show_authorize
    goods_error = resource_class.find(params[:id])
    get_resource_ivar || set_resource_ivar(goods_error)
    goods_error.build_gerror_authorize
  end
  #显示查询窗口
  def search
    render :partial => "search"
  end
end
