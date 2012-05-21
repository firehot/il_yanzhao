class ChangeCarryingBillType < ActiveRecord::Migration
  def up
    change_column :carrying_bills,:type,:string,:limit => 100
  end

  def down
    change_column :carrying_bills,:type,:string,:limit => 20
  end
end
