#coding: utf-8
class AddGoodsCatIdToCarryingBill < ActiveRecord::Migration
  def up
=begin
    add_column :carrying_bills, :goods_cat_id, :integer
    add_index :carrying_bills,:goods_cat_id
=end
#对于carrying_bills这样的表来说,太慢了
    #参考http://onehub.com/blog/posts/adding-columns-to-large-mysql-tables-quickly/
    sql = ActiveRecord::Base.connection()
    sql.execute "SET autocommit=0"
    sql.begin_db_transaction
    sql.execute("CREATE TABLE carrying_bills_new LIKE carrying_bills")
    add_column :carrying_bills_new, :goods_cat_id, :integer
    add_column :carrying_bills_new, :unit_price, :decimal,:precision => 15,:scale => 3,:default => 0
    add_index :carrying_bills_new,:goods_cat_id
    change_column :carrying_bills_new,:type,:string,:limit => 100
    sql.execute("INSERT INTO carrying_bills_new SELECT *, NULL, 0.00 FROM carrying_bills")
    rename_table :carrying_bills, :carrying_bills_old
    rename_table :carrying_bills_new, :carrying_bills
    sql.commit_db_transaction
  end
  def down
    #FIXME 此操作比较危险,应手工进行删除
    #drop_table :carrying_bills
    #rename_table :carrying_bills_old, :carrying_bills
  end
end
