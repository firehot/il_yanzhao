#coding: utf-8
class GoodsException < ActiveRecord::Base
  belongs_to :carrying_bill
  belongs_to :user
  belongs_to :org
  #处理部门
  belongs_to :op_org,:class_name => "Org"

  #授权核销信息
  has_one :gexception_authorize_info
  #理赔信息
  has_one :claim
  #责任鉴定信息
  has_one :goods_exception_identify
  accepts_nested_attributes_for :gexception_authorize_info,:claim,:goods_exception_identify

  #异常数量不能大于货物数量
  validates_presence_of :org_id,:carrying_bill,:op_org_id
  validate :check_except_num
  #定义状态机
  state_machine :initial => :submited do
    event :process do
      #已上报 -- 已授权核销 --- 已赔偿 -- 责任已鉴定
      transition :submited =>:authorized,:authorized => :compensated,:compensated => :identified
    end
  end

  #FIXME 缺省值设定应定义到state_machine之后
  default_value_for :bill_date do
    Date.today
  end

  #EXCEPT_LACK= "LA"           #少货
  EXCEPT_SHORTAGE = "SH"      #短缺
  EXCEPT_DAMAGED = "DA"       #破损
  #付款方式描述
  def self.exception_types
    {
#      "少货" => EXCEPT_LACK,          #少货
      "丢缺" => EXCEPT_SHORTAGE,      #短缺
      "破损" => EXCEPT_DAMAGED        #破损
    }
  end
  def except_des
      except_des = ""
      GoodsException.exception_types.each {|des,code| except_des = des if code == self.exception_type }
      except_des
  end
  #发货地赔付金额
  def from_fee
    self.goods_exception_identify.try(:from_org_fee)
  end
  def to_fee
    self.goods_exception_identify.try(:to_org_fee)
  end
  #到货地赔付金额
  private
  def check_except_num
    errors.add(:except_num,"不能大于货物数量") if self.carrying_bill and self.except_num > self.carrying_bill.goods_num
  end
end
