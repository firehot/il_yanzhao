#coding: utf-8
class GoodsCat < ActiveRecord::Base
  acts_as_tree :order => :order_by
  validates :name,:presence => true
  has_many :goods_cat_promotions
  accepts_nested_attributes_for :goods_cat_promotions,:reject_if => proc {|attrs| attrs['from_fee'].eql?('0') and attrs['to_fee'].eql?('0')}
  after_initialize :build_goods_cat_promotions
  private
  def build_goods_cat_promotions
    (10 - self.goods_cat_promotions.size).times { self.goods_cat_promotions.build }
  end
end
