#coding: utf-8
#中转机打运单
class TransitBill < CarryingBill
  before_save :generate_goods_no
  before_create :generate_bill_no
  validates_presence_of :transit_org_id,:area_id
  #验证中转运费和中转手续费不可大于运费
  validate :check_transit_fee
end
