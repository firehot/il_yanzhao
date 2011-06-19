#coding: utf-8
class TransitDeliverInfo < ActiveRecord::Base
  belongs_to :org
  belongs_to :user
  has_many :carrying_bills
  validates_presence_of :org_id

  validates_associated :carrying_bills,:message => "中转手续费不能大于原运费."

  default_scope :include => :carrying_bills
  #定义状态机
  state_machine :initial => :billed do
    after_transition do |deliver,transition|
      deliver.carrying_bills.each {|bill| bill.standard_process}
    end
    event :process do
      transition :billed =>:deliveried
    end
  end

  default_value_for :bill_date,Date.today
end
