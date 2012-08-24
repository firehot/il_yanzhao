# -*- encoding : utf-8 -*-
class PayInfo < ActiveRecord::Base
  has_many :carrying_bills,:order => "goods_no ASC"

  belongs_to :user
  belongs_to :org
  validates_presence_of :customer_name,:id_number,:account_no
  #定义状态机
  state_machine :initial => :billed do
    after_transition do |pay_info,transition|
      pay_info.carrying_bills.each {|bill| bill.standard_process}
    end
    event :process do
      transition :billed =>:paid
    end
  end

  default_value_for :bill_date do
    Date.today
  end
  #合计货款
  def sum_goods_fee
    self.carrying_bills.sum(:goods_fee)
  end
  #合计扣手续费
  def sum_k_hand_fee
    self.carrying_bills.sum(:k_hand_fee)
  end
  #合计扣运费
  def sum_k_carrying_fee
    self.carrying_bills.to_a.sum(&:k_carrying_fee)
  end
  #合计扣运费
  def sum_transit_hand_fee
    self.carrying_bills.sum(:transit_hand_fee)
  end

  #合计应付金额
  def sum_act_pay_fee
    self.carrying_bills.to_a.sum(&:act_pay_fee)
  end
  #运单编号
  def bill_no
    self.carrying_bills.join(",")
  end
  #发货人
  def from_customer
    ret = self.carrying_bills.collect {|bill| bill.from_customer_name}.join("-")
    ret
  end
  #导出
  def self.to_csv(search_obj)
      search_obj.export_csv(self.export_options)
  end
  private
  def self.export_options
    {
      :only => [],
      :methods => [
        :bill_no,:bill_date,:from_customer,:sum_goods_fee,:sum_k_carrying_fee,:sum_k_hand_fee,:sum_act_pay_fee,:note
    ]
    }
  end
end
