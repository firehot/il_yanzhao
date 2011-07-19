class AddOrderToOrg < ActiveRecord::Migration
  def self.up
    #添加列表顺序
    add_column :orgs, :order_by, :integer,:default => 0
    #更新org功能的default_action
    sf = SystemFunction.find_by_subject_title("组织机构管理")
    sf.update_attributes(:default_action => "orgs_path('search[is_active_eq]' => 1 )") if sf.present?
    Notify.create(:notify_text => "tip: alt + t : 新建机打运单 ctrl + z 运单高级查询 n:新建 e:修改 s:保存 f:查询 d:删除 p:打印 x:导出")
  end

  def self.down
    remove_column :orgs, :order_by
  end
end
