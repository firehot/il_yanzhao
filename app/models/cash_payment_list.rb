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
  #TODO 应根据需要设置短信提醒文本
  #生成短信通知文本信息
  def export_sms_text
    #去除固定电话
    sms_bills = self.carrying_bills.find_all {|bill| bill.sms_mobile.present? }
    group_sms_bills = sms_bills.group_by(&:sms_mobile)
    #分别合计货物件数/运费合计/货款合计
    sms_text = ''
    group_sms_bills.each do |key,bills|
      goods_num = bills.to_a.sum(&:goods_num)
      carrying_fee_th = 0.0
      bills.each {|the_bill| carrying_fee_th += the_bill.carrying_fee if the_bill.pay_type.eql?(CarryingBill::PAY_TYPE_TH)}
      goods_fee = bills.to_a.sum(&:goods_fee)
      sms_text += "#{key} #{IlConfig.client_name}到货,共#{goods_num}件,运费#{carrying_fee_th}元,货款#{goods_fee}元,地址:#{self.org.try(:location)},电话:#{self.org.try(:phone)}\r\n"
    end
    sms_text
  end
end

