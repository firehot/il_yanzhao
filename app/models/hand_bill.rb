# -*- encoding : utf-8 -*-
#手工运单
class HandBill < CarryingBill
  validate :check_goods_no
  validates_presence_of :to_org_id,:bill_no,:goods_no
  #手工运单,编号从0 ～ 3999999
  validates_inclusion_of :bill_no,:in => '0000000'..'3999999'
    #默认货号
  default_value_for :goods_no do
    Date.today.strftime('%y%m%d')
  end
  private
  #手工运单验证货号与发货地和收货地是否匹配
  def check_goods_no
    errors.add(:goods_no,"与发货地或收货地不匹配.") unless self.goods_no.include?("#{self.from_org.try(:simp_name)}#{self.to_org.try(:simp_name)}")
  end
end

