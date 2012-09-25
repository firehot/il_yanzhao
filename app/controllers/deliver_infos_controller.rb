# -*- encoding : utf-8 -*-
#coding: utf-8
class DeliverInfosController < BaseController
  table :org,:deliver_date,:bill_no,:customer_name,:customer_no,:sum_carrying_fee_th,:sum_insured_fee_th,:sum_from_short_carrying_fee_th,:sum_to_short_carrying_fee_th,:sum_carrying_fee_th_total,:sum_goods_fee,:sum_th_amount
  include BillOperate

  #重写index方法
  def index
    super do |format|
      format.html
      format.csv {send_data resource_class.to_csv(@search)}
    end
  end

  #GET search
  #显示查询窗口
  def search
    render :partial => "search"
  end
end

