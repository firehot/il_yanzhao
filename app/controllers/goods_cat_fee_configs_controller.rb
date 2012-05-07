#coding: utf-8
class GoodsCatFeeConfigsController < BaseController
  skip_before_filter :pre_process_search_params
  skip_authorize_resource :only => [:single_config_line]
  #根据客户端传入的参数获取给定的货物分类的运费设置信息
  #GET goods_cat_fee_configs/single_config_line
  def single_config_line
    @goods_cat_fee_config_line = GoodsCatFeeConfigLine.search_line(params)
    respond_to do |format|
      format.js {render :json => @goods_cat_fee_config_line }
    end
  end
end
