#coding: utf-8
#中转机打运单
class TransitBill < CarryingBill
  before_validation :generate_goods_no
  before_validation :generate_bill_no,:on => :create

  validates :bill_no,:goods_no,:transit_org_id,:area_id,:presence => true
  #验证中转运费和中转手续费不可大于运费
  validate :check_transit_fee
end
