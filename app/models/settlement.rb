#coding: utf-8
class Settlement < ActiveRecord::Base
  belongs_to :user
  has_many :carrying_bills,:order => "goods_no ASC"

  belongs_to :org
  validates_presence_of :org_id
  #定义状态机
  state_machine :initial => :billed do
    after_transition :on => :process,:billed => :settlemented do |settlement,transition|
      settlement.carrying_bills.each {|bill| bill.standard_process}
    end
    event :process do
      transition :billed =>:settlemented,:settlemented => :confirmed
    end

    #直接返款确认,中转部门使用
#    event :direct_refunded_confirmed do
#      transition :settlemented =>:refunded_confirmed
#    end
#    after_transition :on => :direct_refunded_confirmed do |settlement,transition|
#      settlement.carrying_bills.each {|bill| bill.direct_refunded_confirmed}
#    end
    #财务收款确认
    event :confirm do
      transition :settlemented =>:confirmed
    end

  end

  default_value_for :bill_date do
    Date.today
  end
  #结算员
  def user_name
    self.user.try(:username)
  end

  #组织机构
  def org_name
    self.org.name
  end
  #合计
  def sum_fee
    self.sum_carrying_fee + self.sum_goods_fee - self.sum_transit_carrying_fee - self.sum_transit_hand_fee
  end
  #导出到csv
  def to_csv
    ret = ["结算员:",self.user_name,"结算单位:",self.org_name,"结算日期:",self.bill_date].export_line_csv(true)
    ret = ret + ["提付运费:",self.sum_carrying_fee,"代收货款:",self.sum_goods_fee,"合计:",self.sum_fee].export_line_csv
    csv_carrying_bills = CarryingBill.to_csv(self.carrying_bills.search,Settlement.carrying_bill_export_options,false)
    ret + csv_carrying_bills
  end
  private
  def self.carrying_bill_export_options
    {
        :only => [],
        :methods => [
          :bill_date,:bill_no,:goods_no,:from_customer_name,:from_customer_phone,:from_customer_mobile,
          :to_customer_name,:to_customer_phone,:to_customer_mobile,
          :pay_type_des,
          :carrying_fee_th,:goods_fee,:insured_fee,
          :note,:human_state_name
      ]}
  end
end
