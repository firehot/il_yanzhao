# -*- encoding : utf-8 -*-
class CashPaymentList < PaymentList
  attr_protected :bank_id
  validates :org_id,:presence => true
  #定义状态机
  state_machine :initial => :billed do
    after_transition do |payment_list,transition|
      payment_list.carrying_bills.each {|bill| bill.standard_process}
    end
    event :process do
      transition :billed =>:payment_listed
    end
  end
  # 应根据需要设置短信提醒文本
  #生成短信通知文本信息
  def export_sms_text
    #去除固定电话
    sms_bills = self.carrying_bills.find_all {|bill| bill.sms_mobile.present? and bill.goods_fee > 0 }
    sms_text = ''
    sms_bills.each do |bill|
      sms_text += Settings.notice_cash_payment_list.sms % [bill.bill_no,IlConfig.client_name]
    end
    sms_text
  end
end

