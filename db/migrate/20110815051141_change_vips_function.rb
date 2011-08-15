class ChangeVipsFunction < ActiveRecord::Migration
  def self.up
    sf = SystemFunction.find_by_subject_title('转账客户管理')
    sf.default_action = 'vips_path("search[org_id_in]" => current_user.current_ability_org_ids)'
    sf.save!
    sfo = sf.system_function_operates.find_by_name('查看')
    sfo.function_obj = {
      :subject => Vip,
      :action => :read
    }
    sfo.save!
  end

  def self.down
  end
end
