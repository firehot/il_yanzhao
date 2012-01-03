#coding: utf-8
#实际装车清单明细
class ActLoadListLine < ActiveRecord::Base
  belongs_to :carrying_bill
  belongs_to :act_load_list
  validates_presence_of :carrying_bill
  validates_numericality_of :load_num
end
