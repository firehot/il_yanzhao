#coding: utf-8
#基于条形码的装车清单对象
class LoadListWithBarcode < ActiveRecord::Base
  attr_accessible :bill_date, :bill_no, :note, :to_org_id, :user_id,:load_list_with_barcode_lines_attributes

  belongs_to :to_org,:class_name => "Org"
  belongs_to :user
  belongs_to :confirmer,:class_name => "User"
  has_many :load_list_with_barcode_lines
  accepts_nested_attributes_for :load_list_with_barcode_lines
  validates_presence_of :to_org_id
  default_value_for :bill_date do
    Date.today
  end
  #定义状态机
  state_machine :initial => :draft do
    #到货确认后,设置确认时间
    after_transition do |l,transition|
      l.update_attributes(:confirm_date => Date.today)
    end
    event :confirm do
      transition :draft =>:confirmed
    end
  end
end
