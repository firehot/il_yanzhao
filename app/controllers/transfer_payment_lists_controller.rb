#coding: utf-8
class TransferPaymentListsController < BaseController
  table :bill_date,:bank,:user,:note,:human_state_name
  include BillOperate
  #GET search
  #显示查询窗口
  def search
    render :partial => "search"
  end
  def show
    super do |format|
      format.csv {send_data resource.to_csv,:filename => 'pufa.csv'}
      format.text {send_data resource.ccb_to_txt,:filename => 'icbc.txt'}
    end
  end
  #导出到EXCEL
  #GET transfer_payment_list/:id/export_excel
  def export_excel
    @transfer_payment_list = resource_class.find(params[:id],:include => [:bank,:user,:carrying_bills])
  end
end
