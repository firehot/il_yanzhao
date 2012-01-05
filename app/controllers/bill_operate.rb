#coding: utf-8
module BillOperate
  def create
    bill = resource_class.new(params[resource_class.model_name.underscore])
    get_resource_ivar || set_resource_ivar(bill)
    bill.carrying_bill_ids  = params[:bill_ids]  unless params[:bill_ids].blank?
    bill.process
    create!
  end
  #PUT/:load_list_id/process_handle
  def process_handle
    bill = resource_class.find(params[:id])
    bill = resource_class.includes(:carrying_bills).find(params[:id]) if bill.respond_to? :carrying_bills
    get_resource_ivar || set_resource_ivar(bill)
    bill.process ? flash[:success] = "数据处理成功!" : flash[:error] = "数据处理失败!"
    render  :show
  end
  #票据打印
  module BillPrint
    #PUT computer_bills/:id/print_counter
    #打印计数,每打印一次,计数+1
    def print_counter
      bill = resource_class.find(params[:id])
      get_resource_ivar || set_resource_ivar(bill)
      resource_class.increment_counter(:print_counter,bill.id)
      render :nothing => true
    end
  end
end
