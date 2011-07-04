#coding: utf-8
class ConfigTransit < ActiveRecord::Base
  validates_presence_of :rate,:name
  belongs_to :org
  belongs_to :to_org,:class_name => "Org"
  #计算手续费


end
