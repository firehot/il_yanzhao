#coding: utf-8
require "fastercsv"

namespace :db do
  desc "对carrying_bills表进行分表操作"
  task :partition_carrying_bills => :environment do
    c = ActiveRecord::Base.connection
    #修改carrying_bill id的定义,便于进行分表操作


    c.execute("ALTER TABLE carrying_bills MODIFY id INT(11) NOT NULL")
    c.execute("ALTER TABLE carrying_bills DROP PRIMARY KEY")
    c.execute("ALTER TABLE carrying_bills ADD PRIMARY KEY (id,completed)")
    c.execute("ALTER TABLE carrying_bills MODIFY id INT(11) NOT NULL AUTO_INCREMENT")

    #以下添加mysql 分区表
    c.execute("ALTER TABLE carrying_bills
            partition by list(completed)
            (
            partition p0 values in(0),
            partition p1 values in(1)
           )")

  end
  desc "自lmis系统中导入org资料"
  task :imp_org => :environment do
    FILE_NAME=Rails.root.join('db/export/info_org.csv')
    Org.destroy_all
    rows = FasterCSV::read(FILE_NAME)
    rows.each do |row|
      org = Branch.new_with_config(:name => row[9],:simp_name => row[9],:location => row[8],:code => row[14])
      org.save!
    end
    #查找郑州总公司
    zz_branch = Branch.find_by_name("郑州总公司")
    Branch.all.each do |b|
      if ('A'..'Z').include?(b.name)
        b.update_attributes(:parent_id => zz_branch.id)
      end
    end
  end

  desc "自lmis系统中导入转账客户资料"
  task :imp_customer => :environment do
    FILE_NAME=Rails.root.join('db/export/crm_customer.csv')
    Vip.skip_callback(:create,:before,:set_code)
    Vip.destroy_all
    #银行信息,只有建设银行和浦发银行
    icbc = Bank.find_or_create_by_name_and_code("建行",8)
    icbc = Bank.find_or_create_by_name_and_code("浦发",2)

    rows = FasterCSV::read(FILE_NAME)
    rows.each do |row|
      customer_no = row[26]
      #根据客户编号得到客户所属机构和开户银行
      if customer_no.present? and (customer_no.start_with?("8") or customer_no.start_with?("2"))
        id_number = row[28]
        bank_code = customer_no[0,1]
        org_code = customer_no[1,2]
        the_bank = Bank.find_by_code(bank_code)
        the_org = Branch.find_by_code(org_code)
        if the_bank.present? and the_org.present? and !Vip.exists?(:code => customer_no) and id_number.present?
          vip = Vip.new(:org => the_org,:bank => the_bank,:name => row[8],:phone => row[11],:mobile => row[12],:bank_card => row[14],:id_number => row[28])
          vip.code = row[26]
          vip.save!
        end
      end
    end
  end

  desc "向数据库中添加示例数据"
  task :gen_test_data => :environment do
    Rake::Task['db:reset'].invoke
    zz_branch = Branch.create!(:name => "郑州公司",
                               :simp_name => "郑",
                               :manager => "李保庆",
                               :code => "zz",
                               :is_yard => true,
                               :location => "南四环十八里河")
    ('A'..'Z').each do |n|
      branch = Branch.new(:name => n,:simp_name => n,:code => n)
      zz_branch.children << branch
    end
    %w[
    邱县 焦作 永年 馆陶 三门峡 洛阳 周口 肥乡 广平 成安 长治 石家庄 水冶 偃师 许昌 曲周 濮阳 新乡
    魏县 驻马店 宁晋 晋城 双桥 肉联厂 磁县 漯河 临漳 沙河 涉县 大名 鸡泽 侯马 峰峰 武安 邯郸 邢台].each_with_index do |name,index|
      Branch.create!(:name => name,:simp_name => name.first,:location => name,:code => index + 1)
    end
    #银行信息,只有建设银行和浦发银行
    Bank.create!(:name => "建行",:code => 8)
    Bank.create!(:name => "浦发",:code => 2)
    #转账手续费设置
    common_config = ConfigTransit.create(:name => "普通客户",:rate => 0.002)
    vip_config = ConfigTransit.create(:name => "VIP客户",:rate => 0.001)
  end
  #######################################################################################################3
  desc "创建默认用户"
  task :create_user => :environment do
    #创建系统默认用户
    role = Role.new_with_default(:name => '管理员角色')
    role.role_system_function_operates.each { |r| r.is_select = true }
    role.save!

    #管理员角色
    admin = User.new_with_roles(:username => 'admin',:real_name => "管理员",:password => 'admin',:is_admin => true)
    admin.user_orgs.each { |user_org| user_org.is_select = true }
    admin.user_roles.each {|user_role| user_role.is_select = true}
    admin.save!
    #普通用户角色
    user = User.new_with_roles(:username => 'user',:real_name => "普通用户",:password => 'user')
    user.user_orgs.each { |user_org| user_org.is_select = true }
    user.user_roles.each {|user_role| user_role.is_select = true}
    user.save!
  end
  desc "清空业务数据(保留机构/人员/权限)"
  task :clear_business_data => :environment do
    models = Dir['app/models/*.rb'].map {|f| File.basename(f, '.*').camelize.constantize } - [Ability,AbilityObj,Bank,Branch,ConfigCash,ConfigTransit,Customer,CustomerFeeInfo,CustomerFeeInfoLine,CustomerFeeInfoLineObserver,CustomerLevelConfig,Department,IlConfig,ImportedCustomer,Org,Role,RoleSystemFunctionOperate,SystemFunction,SystemFunctionOperate,User,UserOrg,UserRole,Vip,RefoundObserver,SendListModule]
    models.each {|model_class| model_class.destroy_all}
  end

  desc "生成示例数据"
  task :create_bill => :environment do
    #生成1000000张历史票
    from_org = Org.find_by_name('A')
    to_org = Org.find_by_name('邯郸')
    (1..200).each do
      ComputerBill.create!(:from_org => from_org,:to_org => to_org,:from_customer_name => "张三",:from_customer_phone => "1367904567",:to_customer_name => "李四",:to_customer_phone => "2343243",:carrying_fee => 44,:goods_fee => 1000,:pay_type =>"CA",:goods_num => 3,:goods_info => "示例",:user => User.first,:completed => true )
    end
    #生成200000张待处理票
    (1..200).each do
      ComputerBill.create!(:from_org => from_org,:to_org => to_org,:from_customer_name => "张三",:from_customer_phone => "1367904567",:to_customer_name => "李四",:to_customer_phone => "2343243",:carrying_fee => 44,:goods_fee => 1000,:pay_type =>"CA",:goods_num => 3,:goods_info => "示例",:user => User.first )
    end
  end
  desc "导出机构/人员/权限/设置"
  task :export_seed_to_csv => :environment do
    [Bank,Org,ConfigCash,ConfigTransit,CustomerLevelConfig,IlConfig,SystemFunctionGroup,SystemFunction,SystemFunctionOperate,Role,RoleSystemFunctionOperate,User,UserOrg,UserRole].each {|model_class| model_class.export2csv }
  end
  desc "导入机构/人员/权限/设置"
  task :import_seed_csv => :environment do
    [Bank,Org,ConfigCash,ConfigTransit,CustomerLevelConfig,IlConfig,SystemFunctionGroup,SystemFunction,SystemFunctionOperate,Role,RoleSystemFunctionOperate,User,UserOrg,UserRole].each {|model_class| model_class.import_csv }
    #删除机构中无效的数据和权限中无效的数据
    UserOrg.search(:org_is_active_eq => false).each {|uo| uo.destroy}
    Org.destroy_all(:is_active => false)
  end
  desc "初始化系统"
  task :init_system => :environment do
    Rake::Task['db:import_seed_csv'].invoke
    #Rake::Task['db:imp_customer'].invoke
  end
end
