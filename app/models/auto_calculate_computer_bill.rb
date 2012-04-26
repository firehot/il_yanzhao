#coding: utf-8
#自动计算运费运单
class AutoCalculateComputerBill < CarryingBill
  #创建/修改数据前生成票据编号和货号
  before_validation :generate_goods_no
  before_validation :generate_bill_no,:on => :create
  #更新数据时,验证运单号/货号不可为空
  validates :bill_no,:goods_no,:to_org_id,:presence => true
end
