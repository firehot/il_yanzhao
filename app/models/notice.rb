#coding: utf-8
#通知信息主表-语音、短信通知使用
class Notice < ActiveRecord::Base
  belongs_to :org
  belongs_to :load_list
  belongs_to :user
  has_many :notice_lines,:dependent => :delete_all,:include => :carrying_bill
  has_many :carrying_bills,:through => :notice_lines
  #未选中的数据、无电话的数据自动过滤
  accepts_nested_attributes_for :notice_lines,:reject_if => proc {|attrs| attrs['_select'].eql?('0') || attrs['from_customer_phone'].blank? }
  validates_presence_of :org_id,:load_list_id
  default_value_for :bill_date do
    Date.today
  end
end
