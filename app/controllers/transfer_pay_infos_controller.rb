# -*- encoding : utf-8 -*-
#coding: utf-8
class TransferPayInfosController < BaseController
  table :bill_date,:customer_name,:sum_goods_fee,:sum_k_carrying_fee,:sum_transit_hand_fee,:sum_k_hand_fee,:sum_act_pay_fee
  include BillOperate
  #GET search
  #显示查询窗口
  def search
    @search = resource_class.search(params[:search])
    render :partial => "shared/pay_infos/search",:object => @search
  end
  def index
    super do |format|
      format.csv {send_data resource_class.to_csv(@search)}
    end
  end
end

