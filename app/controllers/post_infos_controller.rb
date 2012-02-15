# -*- encoding : utf-8 -*-
#coding: utf-8
class PostInfosController < BaseController
  table :bill_date,:org,:sum_goods_fee,:sum_k_carrying_fee,:sum_k_hand_fee,:sum_act_pay_fee,:human_state_name,:user,:note
  include BillOperate
  #GET search
  #显示查询窗口
  def search
    render :partial => "search"
  end
  def show
    super do |format|
      format.csv {send_data resource.to_csv}
    end
  end
  #GET post_info/1/export_excel
  def export_excel
    @post_info = resource_class.find(params[:id],:include => [:org,:user,:carrying_bills])
  end
end

