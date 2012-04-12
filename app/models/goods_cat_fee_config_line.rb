#coding: utf-8
#货物分类费用设置明细
class GoodsCatFeeConfigLine < ActiveRecord::Base
  belongs_to :goods_cat_fee_config
  belongs_to :goods_cat
  validates :goods_cat,:presence => true
end
