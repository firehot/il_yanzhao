#coding: utf-8
class GoodsCat < ActiveRecord::Base
  acts_as_tree :order => :order_by
  validates :name,:presence => true
end
