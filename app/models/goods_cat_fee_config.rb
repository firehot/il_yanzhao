#coding: utf-8
#货物分类费用设置
class GoodsCatFeeConfig < ActiveRecord::Base
  belongs_to :from_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  has_many :goods_cat_fee_config_lines,:dependent => :destroy
  has_many :goods_cat,:through => :goos_cat_fee_config_lines
  validates :from_org,:to_org,:presence => true
end
