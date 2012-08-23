# -*- encoding : utf-8 -*-
require 'iconv'
class CashPaymentListsController < BaseController
  table :bill_date,:org,:user,:note
  include BillOperate
  #GET search
  #显示查询窗口
  def search
    render :partial => "search"
  end
  def show
    super do |format|
      format.csv {send_data resource.to_csv}
    end
  end
  def export_excel
    @cash_payment_list = resource_class.find(params[:id],:include => [:org,:user,:carrying_bills])
  end
  #Get cash_payment_lists/:id/export_sms_txt:format
  #导出短信群发文本
  def export_sms_txt
    @cash_payment_list = resource_class.find(params[:id])
    respond_to do |format|
      format.text do
        #send_data Iconv.iconv("GB2312","UTF-8",@cash_payment_list.export_sms_txt),:filename => 'sms.txt'
        send_data @cash_payment_list.export_sms_txt,:filename => 'sms.txt'
      end
    end
  end
end

