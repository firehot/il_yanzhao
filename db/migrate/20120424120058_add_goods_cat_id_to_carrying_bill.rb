#coding: utf-8
class AddGoodsCatIdToCarryingBill < ActiveRecord::Migration
  def change
    add_column :carrying_bills, :goods_cat_id, :integer
    add_index :carrying_bills,:goods_cat_id
  end

end
