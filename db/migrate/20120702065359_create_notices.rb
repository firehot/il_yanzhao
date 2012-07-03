#coding: utf-8
#创建通知信息表
class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.references :org,:null => false
      t.references :load_list
      t.references :user
      t.date :bill_date
      t.string :state,:limit => 20,:null => false,:default => 'draft'
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
