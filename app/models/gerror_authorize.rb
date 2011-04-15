#coding: utf-8
class GerrorAuthorize < ActiveRecord::Base
  belongs_to :user
  belongs_to :goods_error
    default_value_for :bill_date,Date.today
end
