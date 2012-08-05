# -*- encoding : utf-8 -*-
#coding: utf-8
class LoadList < ActiveRecord::Base
  belongs_to :from_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  belongs_to :user
  has_many :carrying_bills,:order => "goods_no ASC"
  #可以有多个提醒记录
  has_many :notices

  validates_presence_of :from_org_id,:to_org_id,:bill_no
  validates_associated :carrying_bills
  #待确认收货清单
  scope :shipped,lambda {|to_org_ids| select("sum(1) as bill_count").where(:state => :shipped,:to_org_id => to_org_ids)}
  #定义状态机
  state_machine :initial => :billed do
    after_transition do |load_list,transition|
      load_list.carrying_bills.each {|bill| bill.standard_process}
    end
    #到货确认后,设置确认时间
    after_transition :shipped => :reached do |load_list,transition|
      load_list.update_attributes(:reached_date => Date.today)
    end
    event :process do
      transition :billed =>:loaded,:loaded => :shipped,:shipped => :reached
    end
  end

  #FIXME 缺省值设定应定义到state_machine之后
  default_value_for :bill_date do
    Date.today
  end

  def from_org_name
    ""
    self.from_org.name unless self.from_org.nil?
  end
  def to_org_name
    ""
    self.to_org.name unless self.to_org.nil?
  end
  #生成act_load_list_line
  def build_act_load_list
    act_load_list = ActLoadList.new(:bill_no => self.bill_no,:from_org => self.from_org,:to_org => self.to_org,:load_list => self)
    self.carrying_bills.each do |bill|
      act_load_list.act_load_list_lines.build(:carrying_bill => bill)
    end
    act_load_list
  end
  #2012-7-3
  #创建电话提醒信息,只是创建,并未保存到数据库
  def build_notice
    notice=self.notices.build(:org => self.to_org,:bill_date => self.bill_date,:note => "#{self.bill_date}:#{self.from_org.name} ~ #{self.to_org.try(:name)}")
    notice.notice_lines << self.carrying_bills.map {|bill| NoticeLine.new(:carrying_bill => bill,:from_customer_phone => bill.notice_phone_for_arrive,:calling_text => bill.calling_text_for_arrive,:sms_text => bill.sms_text_for_arrive)}
    notice
  end
  #导出到csv
  def to_csv
    ret = ["清单日期:",self.bill_date,"清单编号:",self.bill_no,"发货站:",self.from_org_name,"到达站:",self.to_org_name,"状态:" , self.human_state_name].export_line_csv(true)
    csv_carrying_bills = CarryingBill.to_csv(self.carrying_bills.search,LoadList.carrying_bill_export_options,false)
    ret + csv_carrying_bills
  end
  #导出sms群发文本
  def to_sms_txt
    return "" unless self.reached?
    #去除固定电话
    sms_bills = self.carrying_bills.find_all {|bill| bill.sms_mobile.present? }
    group_sms_bills = sms_bills.group_by(&:sms_mobile)
    #分别合计货物件数/运费合计/货款合计
    sms_text = ''
    group_sms_bills.each do |key,bills|
      goods_num = bills.to_a.sum(&:goods_num)
      carrying_fee_th = 0.0
      bills.each {|the_bill| carrying_fee_th += the_bill.carrying_fee if the_bill.pay_type.eql?(CarryingBill::PAY_TYPE_TH)}
      goods_fee = bills.to_a.sum(&:goods_fee)
      sms_text += "#{key} #{IlConfig.client_name}到货,共#{goods_num}件,运费#{carrying_fee_th}元,货款#{goods_fee}元,地址:#{self.to_org.try(:location)},电话:#{self.to_org.try(:phone)}\r\n"
    end
    sms_text
  end
  #重写to_s
  def to_s
    self.bill_no
  end

  private
  def self.carrying_bill_export_options
    {
        :only => [],
        :methods => [
          :bill_date,:bill_no,:goods_no,:from_customer_name,:from_customer_phone,:from_customer_mobile,
          :to_customer_name,:to_customer_phone,:to_customer_mobile,
          :pay_type_des,
          :carrying_fee,:goods_fee,
          :note,:human_state_name
      ]}
  end
end

