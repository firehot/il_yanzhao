# -*- encoding : utf-8 -*-
#定义运单scope相关
module CarryingBillExtend
  module Scope
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        #营业额统计
        scope :turnover,select('from_org_id,IFNULL(to_org_id,transit_org_id) as to_org_id,sum(carrying_fee) as sum_carrying_fee,sum(goods_fee) as sum_goods_fee,sum(insured_fee) as sum_insured_fee,sum(from_short_carrying_fee) as sum_from_short_carrying_fee,sum(to_short_carrying_fee) as to_short_carrying_fee,sum(goods_num) as sum_goods_num,sum(1) as sum_bill_count').where(["state <> ? ","invalided"]).group('from_org_id,to_org_id')

        #今日收货
        scope :today_billed,lambda {|from_org_ids| select('pay_type,sum(carrying_fee) as carrying_fee,sum(goods_fee) as goods_fee,sum(insured_fee) as insured_fee,sum(from_short_carrying_fee) as from_short_carrying_fee,sum(to_short_carrying_fee) as to_short_carrying_fee,sum(goods_num) as goods_num,sum(1) as bill_count').where(:from_org_id => from_org_ids,:bill_date => Date.today).where(["state <> ? ","invalided"]).group(:pay_type)}
        #今日提货
        scope :today_deliveried,lambda {|to_org_ids| select('type,pay_type,sum(carrying_fee) as carrying_fee,sum(goods_fee)  as goods_fee,sum(insured_fee) as insured_fee,sum(from_short_carrying_fee) as from_short_carrying_fee,sum(to_short_carrying_fee) as to_short_carrying_fee,sum(goods_num) as goods_num,sum(1) as bill_count').where(:to_org_id => to_org_ids,:state =>:deliveried).search(:deliver_info_deliver_date_eq => Date.today).group('type,pay_type')}
        #今日提款(仅指现金提款)
        scope :today_paid,lambda {|from_org_ids| select('pay_type,sum(carrying_fee) as carrying_fee,sum(insured_fee) as insured_fee,sum(from_short_carrying_fee) as from_short_carrying_fee,sum(to_short_carrying_fee) as to_short_carrying_fee,sum(goods_fee) as goods_fee,sum(goods_num) as goods_num,sum(k_hand_fee) as k_hand_fee,sum(transit_hand_fee) as transit_hand_fee,sum(1) as bill_count').where(:from_org_id => from_org_ids,:state =>:paid).search(:from_customer_id_is_null => 1,:pay_info_bill_date_eq => Date.today).group('pay_type')}
        #最近票据(5张)
        scope :recent_bills,lambda {|from_org_ids| where(:from_org_id => from_org_ids).order("created_at DESC").limit(5)}

        #待提货票据(不包括中转票据)
        scope :ready_delivery,lambda {|to_org_ids| select('sum(1) as bill_count').where(:to_org_id => to_org_ids,:state => :distributed)}
        #待提款票据
        scope :ready_pay,lambda {|from_org_ids| search(:from_customer_id_is_null => 1).where(:from_org_id => from_org_ids,:state => :payment_listed).select('sum(goods_fee) as goods_fee,sum(1) as bill_count')}

        #货款收入情况
        scope :sum_goods_fee_in,lambda {|from_org_ids,date_from,date_to| select('from_org_id,sum(goods_fee) as sum_goods_fee_in').where(:from_org_id => from_org_ids,:state => ["refunded_confirmed","payment_listed","paid","posted"],:updated_at => date_from..date_to).group('from_org_id')}
        #货款支出情况
        scope :sum_goods_fee_out,lambda {|from_org_ids,date_from,date_to| select('from_org_id,sum(goods_fee) as sum_goods_fee_out').where(:from_org_id => from_org_ids,:state => ["paid",'posted'] ,:updated_at => date_from..date_to).group('from_org_id')}

        scope :with_association,:include => [:from_org,:to_org,:transit_org,:send_list_line,:short_fee_info_lines,:user,:notice_lines]
      end
    end
    #below define instance methods
    #class methods
    module ClassMethods ; end
  end
end

