#coding: utf-8
require 'ruby-pinyin/pinyin'
class Org < ActiveRecord::Base
  default_scope order("order_by ASC")
  validates_presence_of :name
  acts_as_tree :order => :name
  before_save :gen_py
  #客户级别设置
  has_many :customer_level_configs
  has_many :user_orgs

  accepts_nested_attributes_for :customer_level_configs

  default_value_for :lock_input_time,"21:30"

  def self.new_with_config(attrs={})
    org = self.new(attrs)
    CustomerLevelConfig.levels.each do |key,value|
      org.customer_level_configs.build(:name => key,:from_fee => CustomerLevelConfig.system_level_range(key).begin,:to_fee => CustomerLevelConfig.system_level_range(key).end)
    end
    org
  end
  #重写to_s方法
  def to_s
    self.name
  end
  #是否超过录单时间
  def input_expire?
    ret = !self.lock_input_time.blank?
    ret = Time.now.strftime('%H:%M') >= self.lock_input_time if self.lock_input_time.present?
    ret
  end

  private
  def gen_py
    py = PinYin.instance
    self.py = py.to_pinyin_abbr(self.name)
  end
end
