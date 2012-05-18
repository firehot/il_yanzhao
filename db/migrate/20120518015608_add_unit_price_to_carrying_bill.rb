#coding: utf-8
#添加单价字段
class AddUnitPriceToCarryingBill < ActiveRecord::Migration
  def change
    add_column :carrying_bills, :unit_price, :decimal,:precision => 15,:scale => 3,:default => 0
  end
end
