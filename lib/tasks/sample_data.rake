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
    FILE_NAME="c:/orgs.csv"
    FILE_NAME="/media/DAT/燕赵项目/orgs.csv"
    Org.destroy_all
    rows = FasterCSV::read(FILE_NAME)
    rows.each do |row|
      Branch.create(:name => row[1],:simp_name => row[2],:location => row[7],:code => row[8])
    end
    #查找郑州总公司
    zz_branch = Branch.find_by_name("郑州总公司")
    zz_branch.update_attributes(:is_yard => true)
    Branch.all.each do |b|
      if ('A'..'Z').include?(b.name)
        b.update_attributes(:parent_id => zz_branch.id)
      end
    end
  end

  desc "自lmis系统中导入转账客户资料"
  task :imp_customer => :environment do
    FILE_NAME="c:/crm_customer.csv"
    FILE_NAME="/media/DAT/燕赵项目/crm_customer.csv"
    Vip.destroy_all
    Bank.destroy_all
    ConfigTransit.destroy_all
    #银行信息,只有建设银行和浦发银行
    icbc = Bank.create!(:name => "建行",:code => 8)
    pf = Bank.create!(:name => "浦发",:code => 2)
    #转账配置
    common_config = ConfigTransit.create!(:name => "普通客户",:rate => 0.002)
    vip_config = ConfigTransit.create!(:name => "VIP客户",:rate => 0.001)


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
        Vip.create!(:org => the_org,:bank => the_bank,:config_transit =>vip_config,:name => row[8],:phone => row[11],:mobile => row[12],:code => row[26],:bank_card => row[14],:id_number => row[28]) if the_bank.present? and the_org.present? and !Vip.exists?(:code => customer_no) and id_number.present?
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
    #客户资料
    #50.times do |index|
    #  Vip.create!(:name => "vip_#{index}",:mobile => ("%07d" % index),:bank => Bank.first,:bank_card =>"%019d" % (index + 1),:org => Branch.first,:id_number => "%018d" % (index + 1),:config_transit => vip_config )
    #end

    #生成示例票据数据
    #各种票据生成50张
    #50.times do |index|
    #  Factory(:computer_bill,:pay_type =>"TH",:from_org => Branch.first,:to_org => Branch.last,:from_customer => Vip.first,:from_customer_name => Vip.first.name,:from_customer_phone => Vip.first.phone)
    #  Factory(:computer_bill,:pay_type =>"TH",:from_org => Org.find_by_py('A'),:to_org => Org.find_by_py('hd'),:from_customer => Vip.first,:from_customer_name => Vip.first.name,:from_customer_phone => Vip.first.phone)
    #  Factory(:computer_bill,:pay_type =>"TH",:from_org => Org.find_by_py('B'),:to_org => Org.find_by_py('qx'),:from_customer => Vip.first,:from_customer_name => Vip.first.name,:from_customer_phone => Vip.first.phone)
    #  Factory(:computer_bill,:pay_type =>"TH",:from_org => Org.find_by_py('C'),:to_org => Org.find_by_py('dm'),:from_customer => Vip.first,:from_customer_name => Vip.first.name,:from_customer_phone => Vip.first.phone)
    #  Factory(:computer_bill,:pay_type =>"TH",:from_org => Org.find_by_py('D'),:to_org => Org.find_by_py('xc'),:from_customer => Vip.first,:from_customer_name => Vip.first.name,:from_customer_phone => Vip.first.phone)
    #  Factory(:hand_bill,:from_org => Branch.first,:to_org => Branch.last,:bill_no => "hand_bill_no_#{index}",:goods_no => "hand_goods_no_#{index}")
    #  Factory(:transit_bill,:from_org => Branch.find_by_py('sjz'),:transit_org => Branch.find_by_py('zzgs'),:to_area => "开封")
    #  Factory(:hand_transit_bill,:from_org => Branch.find_by_py('sjz'),:transit_org => Branch.find_by_py('zzgs'),:to_area => "开封",:bill_no => "hand_transit_bill_no_#{index}",:goods_no => "hand_transit_goods_no_#{index}")
    #  10.times do |index|
    #    TransitCompany.create(:name => "中转公司_#{index}",:address => "中转公司地址_#{index} ")
    #  end
      #送货人
    #  Sender.create(:name => "张三",:mobile => "1212121",:org => Org.find_by_py('xt'))
    #  Sender.create(:name => "李四",:mobile => "1212121",:org => Org.find_by_py('zzgs'))
    #end
  end
end
