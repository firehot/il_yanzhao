#coding: utf-8
#条码装车明细
class LoadListWithBarcodeLine < ActiveRecord::Base
  belongs_to :load_list_with_barcode
  attr_accessible :barcode, :state
end
