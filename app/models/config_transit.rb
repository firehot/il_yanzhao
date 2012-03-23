# -*- encoding : utf-8 -*-
require 'calculate_hand_fee'
class ConfigTransit < ActiveRecord::Base
  include CalculateHandfee
  belongs_to :org
  belongs_to :to_org,:class_name => "Org"
  validates :rate,:numericality => {:greater_than => 0}
  validates :rate,:presence => true
end
