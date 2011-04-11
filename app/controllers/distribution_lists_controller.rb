#coding: utf-8
class DistributionListsController < BaseController
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
  #GET load_list/1/export_excel
  def export_excel
    @distribution_list = resource_class.find(params[:id],:include => [:org,:user,:carrying_bills])
  end

end
