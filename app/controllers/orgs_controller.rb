# -*- encoding : utf-8 -*-
class OrgsController < BaseController
  #使用http缓存数据到客户端
  http_cache :index,:last_modified => Proc.new {|c| c.send(:last_modified)},:etag => Proc.new {|c| c.send(:etag,"org_index")}
  #提取所有机构
  def index
    @orgs = Org.search(params[:search]).order('parent_id ASC,created_at DESC')
  end
  def new
    super do |format|
      format.js {render :partial => "form"}
    end
  end
  def edit
    super do |format|
      format.js {render :partial => "form"}
    end
  end
end
