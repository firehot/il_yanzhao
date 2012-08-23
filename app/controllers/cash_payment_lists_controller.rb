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
        #FIXME 垃圾短信公司,客户端软件不支持utf-8格式的导出文件,只能进行转换
        send_txt = Iconv.conv("gb2312//IGNORE","utf-8",@cash_payment_list.export_sms_txt)
        send_data send_txt,:type => "text/plain;charset=gb2312;header=present",:filename => 'sms.txt'
        #send_data @cash_payment_list.export_sms_txt,:filename => 'sms.txt'
      end
    end
  end
end

