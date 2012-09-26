# -*- encoding : utf-8 -*-
class CarryingBill < ActiveRecord::Base
 #FIXME 数据库中,为使用mysql 分区表功能,将primary key设置为id,completed,此处重新设置为id,防止mysql 运行出错
  self.primary_key = :id
  attr_protected :original_carrying_fee,:original_goods_fee,:original_from_short_carrying_fee,:original_to_short_carrying_fee,:original_insured_amount,:original_insured_fee
  include CarryingBillExtend::PayType
  include CarryingBillExtend::CarryingBill
  include CarryingBillExtend::Association
  include CarryingBillExtend::Callback
  include CarryingBillExtend::DefaultValue
  include CarryingBillExtend::StateMachine
  include CarryingBillExtend::Validations
  include CarryingBillExtend::Scope
  include CarryingBillExtend::Notice
end
