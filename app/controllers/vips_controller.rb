# -*- encoding : utf-8 -*-
#coding: utf-8
class VipsController < BaseController
  table :org_id,:code,:name,:phone,:mobile,:bank_id,:bank_card,:address,:company,:created_at
  #GET search
  #显示查询窗口
  def search
    @search = resource_class.search(params[:search])
    render :partial => "search",:object => @search
  end
  def index
    super do |format|
      format.csv {send_data resource_class.to_csv(@search)}
    end
  end
  #同步运单的发货人名称
  #PUT vip/:id/syn_from_customer_name
  def syn_from_customer_name
    @vip = Vip.find(params[:id])
    @vip.syn_from_customer_name
    flash[:notice]="同步发货人名称完毕!"
    render :action => :show
  end
end
