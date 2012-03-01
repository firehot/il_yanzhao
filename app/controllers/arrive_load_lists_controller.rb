# -*- encoding : utf-8 -*-
#coding： utf-8
#到货清单
class ArriveLoadListsController < LoadListsController
  defaults :resource_class => LoadList, :collection_name => 'load_lists', :instance_name => 'load_list'
  #先跳过基类的验证,然后重写自己的验证
  skip_authorize_resource
  authorize_resource :class => "LoadList",:instance_name => "load_list"
  #Get arrive_load_lists/:id/export_sms_txt:format
  #导出短信群发文本
  def export_sms_txt
    @load_list = resource_class.find(params[:id])
    respond_to do |format|
      format.text do
        send_data @load_list.to_sms_txt,:filename => 'sms.txt'
      end
    end
  end
  protected
  def collection
    @search = end_of_association_chain.accessible_by(current_ability,:read_arrive).search(params[:search])
    get_collection_ivar || set_collection_ivar(@search.select("DISTINCT #{resource_class.table_name}.*").order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]))
  end
end
