# -*- encoding : utf-8 -*-
#手工中转运单
class HandTransitBill < CarryingBill
  validate :check_goods_no,:in => :create
  validates_presence_of :transit_org_id,:area_id,:bill_no,:goods_no
  #手工运单,编号从0 ～ 3999999
  validates_inclusion_of :bill_no,:in => '0000000'..'3999999'
  #验证货号格式
  #验证中转运费和中转手续费不可大运运费
  validate :check_transit_fee

  #默认货号
  default_value_for :goods_no do
    Date.today.strftime('%y%m%d')
  end
  #手工运单验证货号与发货地和收货地是否匹配
  def check_goods_no
    errors.add(:goods_no,"与发货地或中转地不匹配.") unless self.goods_no.include?("#{self.from_org.try(:simp_name)}#{self.transit_org.try(:simp_name)}")
  end
end

