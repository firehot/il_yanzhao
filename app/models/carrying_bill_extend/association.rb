# -*- encoding : utf-8 -*-
# 运单association定义相关
module CarryingBillExtend
  module Association
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        belongs_to :user
        belongs_to :from_org,:class_name => "Org"
        belongs_to :transit_org,:class_name => "Org"
        belongs_to :to_org,:class_name => "Org"
        belongs_to :area

        belongs_to :from_customer,:class_name => "Customer"

        #票据对应的装车清单
        belongs_to :load_list
        belongs_to :distribution_list

        belongs_to :deliver_info
        belongs_to :settlement
        belongs_to :refound
        belongs_to :payment_list
        belongs_to :pay_info
        belongs_to :post_info

        belongs_to :transit_info
        belongs_to :transit_deliver_info

        #于退货单来讲,所对应的原始票据,未退货的票据为空
        belongs_to :original_bill,:class_name => "CarryingBill"
        #对于原始单据来讲,有一个对应的退货单据
        has_one :return_bill,:foreign_key => "original_bill_id",:class_name => "ReturnBill"

        #NOTE 20120424 添加goods_cat
        belongs_to :goods_cat


        #该运单对应的送货信息
        #当前活动的只能有一条
        has_one :send_list_line
        #有多条装车记录
        has_many :act_load_list_lines
        #有多条短途运费明细记录
        has_many :short_fee_info_lines

        #有多条通知明细信息
        has_many :notice_lines
      end
    end
    #类方法
    module ClassMethods;end
  end
end
