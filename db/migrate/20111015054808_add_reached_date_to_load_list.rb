class AddReachedDateToLoadList < ActiveRecord::Migration
  def self.up
    add_column :load_lists, :reached_date, :date
  end

  def self.down
    remove_column :load_lists, :reached_date
  end
end