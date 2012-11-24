#coding: utf-8
#基于条形码的装车清单对象
class LoadListWithBarcode < ActiveRecord::Base
  attr_accessible :bill_date, :bill_no, :note, :to_org_id, :user_id,:load_list_with_barcode_lines_attributes

  belongs_to :to_org,:class_name => "Org"
  belongs_to :user
  has_many :load_list_with_barcode_lines
  accepts_nested_attributes_for :load_list_with_barcode_lines
  validates_presence_of :to_org_id
  default_value_for :bill_date do
    Date.today
  end
end
