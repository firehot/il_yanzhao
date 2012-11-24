#coding: utf-8
#添加基于条码的装车清单表
class CreateLoadListWithBarcodes < ActiveRecord::Migration
  def change
    create_table :load_list_with_barcodes do |t|
      t.integer :to_org_id,:null => false
      t.string :bill_no
      t.date :bill_date,:null => false
      t.text :note
      t.integer :user_id

      t.timestamps
    end
  end
end
