# -*- encoding : utf-8 -*-
#coding: utf-8
#实际装车清单明细
class ActLoadListLine < ActiveRecord::Base
  #虚拟属性,用于判断数据是否选中
  attr_accessor :_select
  belongs_to :carrying_bill
  belongs_to :act_load_list
  validates_presence_of :carrying_bill
  validates_numericality_of :load_num
  #装车数量要小于等于运单剩余未装车数量
  validates_numericality_of :load_num,:less_than_or_equal_to => Proc.new {|line| line.carrying_bill.rest_goods_num },:message => "不能大于剩余数量"

  default_value_for :_select,true
  default_value_for :load_num do |line|
    line.carrying_bill.try(:rest_goods_num)
  end
end

