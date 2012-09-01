# -*- encoding : utf-8 -*-
#coding： utf-8
#到货清单
require 'iconv'
class ArriveLoadListsController < LoadListsController
  defaults :resource_class => LoadList, :collection_name => 'load_lists', :instance_name => 'load_list'
  #先跳过基类的验证,然后重写自己的验证
  skip_authorize_resource
  authorize_resource :class => "LoadList",:instance_name => "load_list"

  #显示导出短信文本界面
  #GET arrive_load_lists/:id/show_export_sms
  def show_export_sms
    @load_list = resource_class.find(params[:id])
  end
  #Get arrive_load_lists/:id/export_sms_txt:format
  #导出短信群发文本
  def export_sms_txt
    @load_list = resource_class.find(params[:id])
    respond_to do |format|
      format.text do
        #FIXME 垃圾短信公司,客户端软件不支持utf-8格式的导出文件,只能进行转换
        send_txt = Iconv.conv("gb2312//IGNORE","utf-8",@load_list.to_sms_txt(params[:bill_ids]))
        send_data send_txt,:type => "text/plain;charset=gb2312;header=present",:filename => 'sms.txt'
      end
    end
  end
  #GET arrive_load_list/:id/build_notice
  #创建到货提醒信息
  def build_notice
    @load_list = resource_class.find(params[:id])
    @notice = @load_list.build_notice
  end
  protected
  def collection
    @search = end_of_association_chain.accessible_by(current_ability,:read_arrive).search(params[:search])
    get_collection_ivar || set_collection_ivar(@search.select("DISTINCT #{resource_class.table_name}.*").order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]))
  end
end
