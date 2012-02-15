#coding: utf-8
class AddSumTransitCarryingFeeToRefound < ActiveRecord::Migration
  def self.up
    #合计中转运费
    add_column :refounds, :sum_transit_carrying_fee, :decimal,:scale => 2,:precision => 10,:default => 0
    #合计中转手续费
    add_column :refounds, :sum_transit_hand_fee, :decimal,:scale => 2,:precision => 10,:default => 0

  end

  def self.down
    remove_column :refounds, :sum_transit_carrying_fee
    remove_column :refounds, :sum_transit_hand_fee
  end
end
