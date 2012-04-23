#coding: utf-8
class GoodsCatPromotion < ActiveRecord::Base
  belongs_to :goods_cat
  validates :goods_cat,:presence => true
  validates :from_fee,:to_fee,:promotion_rate,:numericality => true
end
