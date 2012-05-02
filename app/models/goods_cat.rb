#coding: utf-8
require 'ruby-pinyin/pinyin'
class GoodsCat < ActiveRecord::Base
  acts_as_tree :order => :order_by
  default_scope includes(:goods_cat_promotions)
  validates :name,:presence => true
  has_many :goods_cat_promotions
  validates_associated :goods_cat_promotions
  accepts_nested_attributes_for :goods_cat_promotions
  after_initialize :build_goods_cat_promotions
  before_create :gen_py
  private
  def build_goods_cat_promotions
    (10 - self.goods_cat_promotions.size).times { self.goods_cat_promotions.build }
  end
  def gen_py
    py = PinYin.instance
    self.py = py.to_pinyin_abbr(self.name)
  end

end
