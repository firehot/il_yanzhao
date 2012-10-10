# -*- encoding : utf-8 -*-
#coding: utf-8
class IlConfig < ActiveRecord::Base
  validates_presence_of :key
  validates :key,:presence => true,:uniqueness => true
  #保价费设置比例
  #废弃不用
  KEY_INSURED_RATE = 'insured_rate'

  #保价费
  KEY_INSURED_FEE = 'insured_fee'

  #运费大于指定金额才产生保险费
  KEY_CARRYING_FEE_GTE_ON_INSURED_FEE = "carrying_fee_gte_on_insured_fee"

  #用户名称设置
  KEY_CLIENT_NAME = "client_name"
  #logo设置
  KEY_LOGO = "client_logo"
  #title
  KEY_TITLE = 'system_title'
  def self.insured_rate
    insured_rate ||= self.find_by_key(KEY_INSURED_RATE)
    insured_rate ||= self.create(:key => KEY_INSURED_RATE,:title => '保价费比例设置',:value => '0.003')
    insured_rate.value
  end
  #保险费,默认2元
  def self.insured_fee
    insured_fee ||= self.find_by_key(KEY_INSURED_FEE)
    insured_fee ||= self.create(:key => KEY_INSURED_FEE,:title => '保价费比例设置',:value => '2')
    insured_fee.value
  end
  #运费大于等于指定金额时才产生保险费
  def self.carrying_fee_gte_on_insured_fee
    carrying_fee_gte ||= self.find_by_key(KEY_CARRYING_FEE_GTE_ON_INSURED_FEE)
    carrying_fee_gte ||= self.create(:key => KEY_CARRYING_FEE_GTE_ON_INSURED_FEE,:title => '运费大于等于指定金额时才产生保险费',:value => '16')
    carrying_fee_gte.value
  end

  def self.client_name
    client_name ||=self.find_by_key(KEY_CLIENT_NAME)
    client_name ||= self.create(:key => KEY_CLIENT_NAME,:title => '公司名称',:value => 'XXX物流公司')
    client_name.value
  end
  def self.client_logo
    client_logo ||= self.find_by_key(KEY_LOGO)
    client_logo ||= self.create(:key => KEY_LOGO,:title => '公司标志',:value => '/assets/logo.png')
    client_logo.value
  end
  def self.system_title
    system_title ||= self.find_by_key(KEY_TITLE)
    system_title ||= self.create(:key => KEY_TITLE,:title => '系统名称',:value => 'IL综合物流业务系统')
    system_title.value
  end
end

