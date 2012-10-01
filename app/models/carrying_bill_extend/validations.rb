# -*- encoding : utf-8 -*-
class CustomerCodeValidator < ActiveModel::EachValidator
  def validate_each(object,attribute,value)
    if value.present?
      from_customer = Customer.find_by_code_and_name_and_is_active(value,object.from_customer_name,true)
      if from_customer.blank?
        object.errors[attribute] <<(options[:message] || "客户编号与姓名不匹配" )
      else
        object.from_customer = from_customer
      end
    else #如果customer_code为null
      object.from_customer = nil
    end
  end
end
module CarryingBillExtend
  module Validations
    def self.included(base)
      base.class_eval do
        #验证运费支付方式为从货款扣时,货款必须大于运费,否则不能保存
        validate :check_k_carrying_fee

        #运单编号为7位数字
        validates_format_of :bill_no,:with => /^(TH)*\d{7}$/
        #验证运单号码是否正确
        validates_format_of :goods_no, :with => /(\d{6})(\p{any}{2})(\d{1,10})-(\d{1,10})/
        validates_presence_of :bill_date,:pay_type,:from_customer_name,:to_customer_name,:from_customer_mobile,:to_customer_mobile,:from_org_id,:goods_info
        validates_length_of :from_customer_mobile,:to_customer_mobile, :is => 11,:on => :create
        validates_numericality_of :insured_fee,:goods_num
        validates_numericality_of :goods_fee,:from_short_carrying_fee,:to_short_carrying_fee,:less_than => 100000
        validates :customer_code,:customer_code => true
        #初始创建运单时,运费必须大于0
        validates :carrying_fee,:numericality => {:greater_than => 0},:on => :create
        #修改运单时,运费大于或等于0
        validates :carrying_fee,:numericality => {:greater_than_or_equal_to => 0},:on => :update
      end
    end
    #验证中转费用
    def check_transit_fee
      errors.add(:transit_carrying_fee,"中转运费不能大于原运费.") if transit_carrying_fee > carrying_fee
      errors.add(:transit_hand_fee,"中转手续费不能大于原运费.") if transit_hand_fee > carrying_fee
    end
    #运费支付方式为从货款扣时,货款必须大于运费
    def check_k_carrying_fee
      errors.add(:k_carrying_fee,"货款金额必须大于运费金额.") if pay_type.eql?(PayType::PAY_TYPE_K_GOODSFEE) and goods_fee <= carrying_fee
    end
  end
end
