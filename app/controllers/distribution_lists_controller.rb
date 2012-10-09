# -*- encoding : utf-8 -*-
#coding: utf-8
class DistributionListsController < BaseController
  include BillOperate
  table :bill_date,:org,:human_state_name,:user,:note
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
  #GET load_list/1/export_excel
  def export_excel
    @distribution_list = resource_class.find(params[:id],:include => [:org,:user,:carrying_bills])
    xls = render_to_string(:partial => "excel",:layout => false)
    send_data show_or_hide_fields_for_export(xls),:filename => "distribute.xls"
  end

end

