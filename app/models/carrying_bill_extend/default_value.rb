# -*- encoding : utf-8 -*-
# 运单默认值相关
module CarryingBillExtend
  module DefaultValue
    def self.included(base)
      base.class_eval do
        #字段默认值
        default_value_for :bill_date do
          Date.today
        end
        default_value_for :goods_num,1
        default_value_for :goods_volume,1
        default_value_for :insured_fee do
          IlConfig.insured_fee
        end
        default_value_for :from_short_carrying_fee,0
        default_value_for :to_short_carrying_fee,0
        default_value_for :insured_amount,0
      end
    end
  end
end

