class AddAreaFunction < ActiveRecord::Migration
  def self.up
    group_name ="基础信息管理"
    #################################用户角色管理################################################
    subject_title = "中转到货地管理"
    subject = "Area"
    sf_hash = {
      :group_name => group_name,
      :subject_title => subject_title,
      :default_action => 'areas_path',
      :subject => subject,
      :function => {
      :read =>{:title => "查看"} ,
      :create => {:title => "新建"},
      :update =>{:title =>"修改"},
      :destroy => {:title => "删除"}
    }
    }
    SystemFunction.create_by_hash(sf_hash)
    #添加几个到货地区
    ["西安","上海","济南","北京"].each {|city_name| Area.create!(:name => city_name)}
  end

  def self.down
  end
end
