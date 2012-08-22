# -*- encoding : utf-8 -*-
class CashPayInfo < PayInfo
  #删除前先回复关联运单状态
  before_destroy :set_carrying_bills_to_payment_listed
  private
  def set_carrying_bills_to_payment_listed
    #将关联运单状态修改为付款前状态
    self.carrying_bills.update_all(:state =>:payment_listed,:pay_info_id => nil)
  end
end

