#coding: utf-8
#实际装车清单
class ActLoadList < ActiveRecord::Base
  belongs_to :load_list
  belongs_to :user
  belongs_to :from_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  has_many :act_load_list_lines,:dependent => :delete_all,:include => :carrying_bill
  has_many :carrying_bills,:through => :act_load_list_lines
  accepts_nested_attributes_for :act_load_list_lines
  default_value_for :bill_date do
    Date.today
  end
  validates_presence_of :from_org,:to_org,:load_list
end
