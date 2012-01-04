#coding: utf-8
#实际装车清单明细
class ActLoadListLine < ActiveRecord::Base
  #虚拟属性,用于判断数据是否选中
  attr_accessor :_select
  belongs_to :carrying_bill
  belongs_to :act_load_list
  validates_presence_of :carrying_bill
  validates_numericality_of :load_num
  default_value_for :_select,true
  default_value_for :load_num do |line|
    line.carrying_bill.try(:goods_num)
  end
end
