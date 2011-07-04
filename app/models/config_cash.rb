#coding: utf-8
class ConfigCash < ActiveRecord::Base
  belongs_to :org
  belongs_to :to_org,:class_name => "Org"
  validates_presence_of :fee_from,:fee_to,:hand_fee
  #得到默认的手续费设置
  #客户需求中
  #< 1000 1元
  #1000 ~ 2000 2元
  #2000 ~ 3000 3元
  def self.default_hand_fee(goods_fee)
    q,r = goods_fee.divmod(1000.0)
    if r > 0
      q + 1
    else
      q
    end
  end
  #根据设置计算手续费
  def self.cal_hand_fee(args={:goods_fee => 0,:from_org_id => nil,:to_org_id => nil})
    goods_fee = args.delete(:goods_fee) {|gf| 0 }
    from_org_id = args.delete(:from_org_id)
    to_org_id = args.delete(:to_org_id)
    configs = ConfigCash.search(:org_id_eq => from_org_id,:to_org_id_eq => to_org_id,:fee_from_lte => goods_fee,:fee_to_gt => goods_fee,:is_active_eq => true).all
    ret = default_hand_fee(goods_fee)
    ret = configs.first.hand_fee if configs.present?
    ret
  end
end
