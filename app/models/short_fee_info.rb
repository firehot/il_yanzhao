#coding: utf-8
class ShortFeeInfo < ActiveRecord::Base
  belongs_to :org
  #核销部门
  belongs_to :op_org,:class_name => "Org"
  belongs_to :user
  has_many :short_fee_info_lines
  has_many :carrying_bills,:through => :short_fee_info_lines
  validates_presence_of :org_id,:bill_date

  #定义状态机
  state_machine :initial => :draft do
    after_transition do |info,transition|
      info.short_fee_info_lines.each do |line|
        line.carrying_bill.write_off_from_short_fee! if info.org_id.eql?(line.carrying_bill.from_org_id)
        line.carrying_bill.write_off_to_short_fee if info.org_id.eql?(line.carrying_bill.to_org_id)
      end
    end
    event :write_off do
      transition :draft =>:offed
    end
  end

  #缺省值设定应定义到state_machine之后
  default_value_for :bill_date do
    Date.today
  end
end
