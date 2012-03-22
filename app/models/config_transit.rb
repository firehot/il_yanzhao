# -*- encoding : utf-8 -*-
#coding: utf-8
class ConfigTransit < ActiveRecord::Base
  validates_presence_of :rate
  belongs_to :org
  belongs_to :to_org,:class_name => "Org"

  #计算手续费
  def self.cal_hand_fee(args={:goods_fee =>0,:from_org_id => nil,:to_org_id => nil})
    goods_fee = args.delete(:goods_fee) {|gf| 0 }
    from_org_id = args.delete(:from_org_id)
    to_org_id = args.delete(:to_org_id)
    configs = ConfigTransit.search(:org_id_eq => from_org_id,:to_org_id_eq => to_org_id,:is_active_eq => true).all
    #默认为千分之1
    ret = 0.001
    ret = configs.first.rate if configs.present?
    (goods_fee*ret).ceil
  end
end
