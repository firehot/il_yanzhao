class AddGoodsErrorFuction < ActiveRecord::Migration
  def self.up
    #################################多货少货登记################################################
    group_name = "理赔管理"
    subject_title = "多货少货登记"
    subject = "GoodsError"
    sf_hash = {
      :group_name => group_name,
      :subject_title => subject_title,
      :subject => subject,
      :default_action => 'goods_errors_path("search[state_ne]" => "authorized")',
      :function => {
      #查看相关运单,其他机构发往当前用户机构的运单
      :read => {:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
      :create => {:title => "新建"},
      :show_authorize => {:title => "核销",:conditions =>"{:state => 'submited',:org_id => user.current_ability_org_ids  }"}
    }
    }
    SystemFunction.create_by_hash(sf_hash)
  end
  def self.down
  end
end
