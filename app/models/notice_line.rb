#coding: utf-8
#通知信息明细
class NoticeLine < ActiveRecord::Base
  include NoticesHelper
  #_select 判断前端是否选中
  attr_accessor :_select
  belongs_to :notice
  belongs_to :carrying_bill
  #虚拟属性,用于判断数据是否选中
  attr_accessor :_select
  default_value_for :_select,true
  before_validation :set_notice_info

  validates :carrying_bill_id,:from_customer_phone,:calling_text,:calling_state,:sms_state,:presence => true

  private
  def set_notice_info
    self.from_customer_phone = carrying_bill.notice_phone_for_arrive
    self.calling_text = carrying_bill.calling_text_for_arrive
    #收货人电话是手机时才生成短信文本
    self.sms_text = carrying_bill.sms_text_for_arrive if mobile?(self.from_customer_phone)
  end
end
