class AddWriteOffDateToShortFeeInfo < ActiveRecord::Migration
  def self.up
    add_column :short_fee_infos, :write_off_date, :date
  end

  def self.down
    remove_column :short_fee_infos, :write_off_date
  end
end