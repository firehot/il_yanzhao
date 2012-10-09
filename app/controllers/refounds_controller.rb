# -*- encoding : utf-8 -*-
class RefoundsController < BaseController
  include BillOperate
  table :bill_date,:from_org,:to_org,:sum_goods_fee,:sum_carrying_fee_th,:sum_insured_fee_th,:sum_from_short_carrying_fee_th,:sum_to_short_carrying_fee_th,:sum_th_amount,:human_state_name,:user
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
  #导出到excel
  #GET /refounds/:id/export_excel
  def export_excel
    @refound = resource_class.find(params[:id],:include => [:from_org,:to_org,:user,:carrying_bills])
    partial = "excel"
    partial = "excel_group" if params[:show_group].present?
    xls = render_to_string(:partial => partial,:layout => false)
    send_data show_or_hide_fields_for_export(xls),:filename => "refund.xls"
  end
end

