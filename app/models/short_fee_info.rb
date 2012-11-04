# -*- encoding : utf-8 -*-
#coding: utf-8
class ShortFeeInfo < ActiveRecord::Base
  belongs_to :org
  #核销部门
  belongs_to :op_org,:class_name => "Org"
  belongs_to :user
  has_many :short_fee_info_lines,:dependent => :destroy
  has_many :carrying_bills,:through => :short_fee_info_lines
  validates_presence_of :org_id,:bill_date

  #定义状态机
  state_machine :initial => :draft do
    after_transition do |info,transition|
      #更新核销时间
      info.update_attributes(:write_off_date => Date.today)
      info.carrying_bills.each do |bill|
        bill.write_off_from_short_fee! if info.org_id.eql?(bill.from_org_id)
        bill.write_off_to_short_fee! if info.org_id.eql?(bill.to_org_id)
      end
    end
    event :write_off do
      transition :draft => :saved,:saved => :offed
    end
  end

  #缺省值设定应定义到state_machine之后
  default_value_for :bill_date do
    Date.today
  end
  #报销金额合
  def sum_write_off_fee
    sum_from = self.carrying_bills.sum(:from_short_carrying_fee,:conditions => {:from_org_id => self.org_id})
    sum_to = self.carrying_bills.sum(:to_short_carrying_fee,:conditions => {:to_org_id => self.org_id})
    sum_from + sum_to
  end
end
