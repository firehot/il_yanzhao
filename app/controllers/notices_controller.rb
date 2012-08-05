#coding: utf-8
#到货提醒,用于语音短信提醒
class NoticesController < BaseController
  table :bill_date,:org,:load_list,:state_desc
  #GET search
  #显示查询窗口
  def search
    respond_to do |format|
      format.html
      format.js  {render :partial => "search"}
    end
  end

end
