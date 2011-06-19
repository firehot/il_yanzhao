#coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#创建系统功能列表

#配送管理模块
group_name = "配送管理"
#################################运单录入################################################
subject_title = "运单录入"
subject = "ComputerBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'computer_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")',
  :function => {
  #查看相关运单,其他机构发往当前用户机构的运单
  :create => {:title => "新建"},
  :destroy => {:title => "删除",:conditions =>"{:state => ['loaded','billed']}"},
  :re_print => {:title => "票据打印",:conditions =>"{:state => 'billed'}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################手工运单录入#################################################
subject_title = "手工运单录入"
subject = "HandBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'hand_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")',
  :function => {
  :create => {:title => "新建"},
  :destroy => {:title => "删除",:conditions =>"{:state => ['loaded','billed']}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################中转运单录入#################################################
subject_title = "中转运单录入"
subject = "TransitBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,

  :default_action => 'transit_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")',
  :subject => subject,
  :function => {
  :create => {:title => "新建"},
  :re_print => {:title => "票据打印",:conditions =>"{:state => 'billed'}"},
  :destroy => {:title => "删除",:conditions =>"{:state => ['loaded','billed']}"},
  :export => {:title => "导出"}

}
}
SystemFunction.create_by_hash(sf_hash)
##############################手工中转运单录入#################################################
subject_title = "手工中转运单录入"
subject = "HandTransitBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,

  :default_action => 'hand_transit_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")',
  :subject => subject,
  :function => {
  :create => {:title => "新建"},

  :destroy => {:title => "删除",:conditions =>"{:state => ['loaded','billed']}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################货物运输清单管理#############################################
subject_title = "货物运输清单管理"
subject = "LoadList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'load_lists_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:from_org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},

  :export => {:title => "导出"},
  :ship => {:title => "发车",:conditions =>"{:from_org_id => user.current_ability_org_ids,:state => 'loaded'}"},
  :destroy => {:title => "删除",:conditions =>"{:from_org_id => user.current_ability_org_ids }"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################到货清单管理#############################################
#NOTE 与load_list是相同的,不过仅仅重新派生了一个controller
subject_title = "到货清单管理"
subject = "LoadList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'arrive_load_lists_path("search[state_eq]" => "shipped")',
  :subject => subject,
  :function => {
  :read_arrive =>{:title => "查看",:conditions =>"{:state => ['shipped','reached'],:to_org_id => user.current_ability_org_ids}"} ,
  :export => {:title => "导出"},
  :reach => {:title => "到货确认",:conditions =>"{:state => 'shipped',:to_org_id => user.current_ability_org_ids}"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################分货物清单管理#############################################
subject_title = "分货清单管理"
subject = "DistributionList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'new_distribution_list_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids}"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}

}
SystemFunction.create_by_hash(sf_hash)
##############################货物中转#############################################
subject_title = "货物中转"
subject = "TransitInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'new_transit_info_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids}"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}

}
SystemFunction.create_by_hash(sf_hash)

##############################提货#############################################
subject_title = "客户提货"
subject = "DeliverInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'new_deliver_info_path',
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :batch_deliver => {:title => "批量提货"},
  :print_deliver => {:title => "打印提货"},
  :print => {:title => "仅打印提货单"},
  :export => {:title => "导出"}
}

}
SystemFunction.create_by_hash(sf_hash)
##############################中转提货#############################################
subject_title = "中转提货"
subject = "TransitDeliverInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'new_transit_deliver_info_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids}"},
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}

}
SystemFunction.create_by_hash(sf_hash)
##############################退货单#################################################
subject_title = "退货单管理"
subject = "ReturnBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'before_new_return_bills_path',
  :subject => subject,
  :function => {
  :create => {:title => "新建"},
  :update =>{:title =>"修改",:conditions =>"{:from_org_id => user.current_ability_org_ids}"},
  :destroy => {:title => "删除",:conditions =>"{:state => ['loaded','billed']}"},
  :re_print => {:title => "票据打印",:conditions =>"{:state => 'billed'}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################短途运费管理#############################################
subject_title = "短途运费管理"
subject = "ShortFeeInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => "short_fee_infos_path",
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :destroy =>{:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
############################################################################################
group_name = "查询统计"
##############################运单查询/修改#################################################
subject_title = "运单修改"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'simple_search_carrying_bills_path("search[completed]" => false,"search[from_org_id_eq]" => current_user.default_org.id,:sort => "carrying_bills.bill_date desc,carrying_bills.goods_no",:direction => "asc" )',
  :subject => subject,
  :function => {
  #:read => {:title => "查询/查看",:conditions =>"{:from_org_id => user.current_ability_org_ids}"},
  :update_all =>{:title =>"修改运单"},
  :update_carrying_fee_20 =>{:title =>"修改运费(20%)"},
  :update_carrying_fee_50 =>{:title =>"修改运费(50%)"},
  :update_carrying_fee_100 =>{:title =>"修改运费(100%)"},
  :reset =>{:title =>"重置运单",:conditions =>"{:from_org_id => user.current_ability_org_ids}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################未提货统计#############################################
subject_title = "未提货报表"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'simple_search_carrying_bills_path(:rpt_type => "rpt_no_delivery",:show_fields =>".stranded_days",:hide_fields => ".insured_fee","search[state_in]" => ["reached","distributed"],"search[from_org_id_eq]" => current_user.default_org.id,:sort => "carrying_bills.bill_date asc,carrying_bills.goods_no",:direction => "asc" )',
  :subject => subject,
  :function => {
  :rpt_no_delivery =>{:title =>"未提货报表"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################本地未提货统计#############################################
subject_title = "本地未提货统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'simple_search_carrying_bills_path(:rpt_type => "rpt_no_delivery",:show_fields =>".stranded_days",:hide_fields => ".insured_fee","search[state_in]" => ["reached","distributed"],"search[to_org_id_eq]" => current_user.default_org.id,:sort => "carrying_bills.bill_date asc,carrying_bills.goods_no",:direction => "asc" )',
  :subject => subject,
  :function => {
  :rpt_no_delivery =>{:title =>"本地未提货统计"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################始发地收货统计#############################################
subject_title = "始发地收货统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'carrying_bills_path(:rpt_type => "rpt_to_me","search[to_org_id_eq]" => current_user.default_org.id,"search[bill_date_gte]" => Date.today.beginning_of_day,"search[bill_date_lte]" => Date.today.end_of_day,:sort => "carrying_bills.bill_date desc,carrying_bills.goods_no",:direction => "asc" )',
  :subject => subject,
  :function => {
  :rpt_to_me =>{:title =>"始发地收货统计"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################提货未提款统计#############################################
subject_title = "提货未提款统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'simple_search_carrying_bills_path(:rpt_type => "rpt_no_pay","search[to_org_id_eq]" => current_user.default_org.id,"search[state_in]" => ["refunded_confirmed","payment_listed"],"search[bill_date_gte]" => Date.today.beginning_of_day,"search[bill_date_lte]" => Date.today.end_of_day,:sort => "carrying_bills.bill_date desc,carrying_bills.goods_no",:direction => "asc")',
  :subject => subject,
  :function => {
  :rpt_no_pay =>{:title =>"提货未提款统计"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################日营业额统计#############################################
subject_title = "日营业额统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'rpt_turnover_carrying_bills_path("search[type_in]" => ["ComputerBill","HandBill","ReturnBill"],"search[bill_date_gte]" => Date.today.beginning_of_day,"search[bill_date_lte]" => Date.today.end_of_day)',
  :subject => subject,
  :function => {
  :rpt_to_me =>{:title =>"日营业额统计"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################日营业额统计图#############################################
subject_title = "日营业额统计图"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'turnover_chart_carrying_bills_path("search[type_in]" => ["ComputerBill","HandBill","ReturnBill"],"search[bill_date_gte]" => Date.today.beginning_of_day,"search[bill_date_lte]" => Date.today.end_of_day)',
  :subject => subject,
  :function => {
  :turnover_chart =>{:title =>"日营业额统计图"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################月营业额统计#############################################
subject_title = "月营业额统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'rpt_turnover_carrying_bills_path("search[type_in]" => ["ComputerBill","HandBill","ReturnBill"],"search[bill_date_gte]" => Date.today.beginning_of_month,"search[bill_date_lte]" => Date.today.end_of_month)',
  :subject => subject,
  :function => {
  :rpt_to_me =>{:title =>"月营业额统计"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################退货未发票据统计#############################################
subject_title = "退货未发票据统计"
subject = "CarryingBill"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'simple_search_carrying_bills_path(:rpt_type => "rpt_return_no_ship",:show_fields =>".stranded_days",:hide_fields => ".insured_fee","search[state_eq]" => "billed","search[type_eq]" => "ReturnBill",:sort => "carrying_bills.bill_date asc,carrying_bills.goods_no",:direction => "asc" )',
  :subject => subject,
  :function => {
  :rpt_return_no_ship =>{:title =>"退货未发票据统计"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################始发地收货统计#############################################

#################################结算管理##########################################
group_name = "结算管理"
##############################settlement#############################################
subject_title = "结算员交款清单"
subject = "Settlement"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'new_settlement_path',
  :subject => subject,
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :direct_refunded_confirmed => {:title => "中转交款确认",:conditions =>"{:org_id => user.current_ability_org_ids,:state => 'settlemented' }" },
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################返款清单管理#############################################
subject_title = "返款清单管理"
subject = "Refound"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'new_refound_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:from_org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################汇款记录#############################################
subject_title = "汇款记录"
subject = "Remittance"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'remittances_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:from_org_id => user.current_ability_org_ids }"} ,
  :update => {:title => "录入汇款记录",:conditions =>"{:state =>'draft' ,:from_org_id => user.current_ability_org_ids }"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)

##############################收款清单管理#############################################
#FIXME 与返款清单是相同的,不过仅仅重新派生了一个controller
subject_title = "收款清单管理"
subject = "Refound"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'receive_refounds_path("search[state_eq]" => "refunded")',
  :subject => subject,
  :function => {
  :read_arrive =>{:title => "查看",:conditions =>"{:state =>['refunded_confirmed','refunded'] ,:to_org_id => user.current_ability_org_ids}"} ,
  :refound_confirm => {:title => "收款确认",:conditions =>"{:state => 'refunded',:to_org_id => user.current_ability_org_ids}"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################现金代收货款支付清单管理-#############################################
subject_title = "现金-代收货款支付"
subject = "CashPaymentList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'cash_payment_lists_path',
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################银行转账代收货款支付清单管理-#############################################
subject_title = "转账-代收货款支付"
subject = "TransferPaymentList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'transfer_payment_lists_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :transfer => {:title => "转账确认"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################客户提款-现金-#############################################
subject_title = "客户提款-现金"
subject = "CashPayInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,

  :default_action => 'new_cash_pay_info_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :batch_pay =>{:title => "批量提款"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################客户提款-转账-#############################################
subject_title = "客户提款-转账"
subject = "TransferPayInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,

  :default_action => 'new_transfer_pay_info_path',
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :batch_pay =>{:title => "批量提款"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################客户提款结算清单#############################################
subject_title = "客户提款结算清单"
subject = "PostInfo"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'post_infos_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
##############################帐目盘点登记表#############################################
subject_title = "帐目盘点登记表"
subject = "Journal"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'journals_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :update =>{:title => "修改",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :export => {:title => "导出"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)

group_name = "基础信息管理"
#################################分理处/分公司管理################################################
subject_title = "组织机构管理"
subject = "Org"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'orgs_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"},
  :edit_lock_time => {:title => "修改录单截至时间"}
}
}
SystemFunction.create_by_hash(sf_hash)
#################################用户信息管理################################################
subject_title = "用户信息管理"
subject = "User"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'users_path',
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
#################################用户角色管理################################################
subject_title = "角色/权限管理"
subject = "Role"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'roles_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)

group_name ="客户关系管理"
#################################客户关系管理################################################
#subject_title = "客户资料管理"
#subject = "Customer"
#sf_hash = {
#  :group_name => group_name,
#  :subject_title => subject_title,
#  :default_action => 'customers_path',
#  :subject => subject,
#  :function => {
#  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
#  :create => {:title => "新建"},
#  :update =>{:title =>"修改",:conditions =>"{:org_id => user.current_ability_org_ids }"},
#  :destroy => {:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"}
#}
#}
#SystemFunction.create_by_hash(sf_hash)

#################################客户关系管理################################################
subject_title = "转账客户管理"
subject = "Vip"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'vips_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
#################################客户分级################################################
subject_title = "客户分级"
subject = "ImportedCustomer"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'imported_customers_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"} ,
  :create => {:title => "新建"}
}
}
SystemFunction.create_by_hash(sf_hash)

group_name ="系统管理"
##################################银行设置###############################################
subject_title = "银行信息设置"
subject = "Bank"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'banks_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
##################################中转公司信息###############################################
subject_title = "中转公司信息"
subject = "TransitCompany"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'transit_companies_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
##################################手续费比例设置-现金###############################################
subject_title = "手续费比例设置-现金"
subject = "ConfigCash"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'config_cashes_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
##################################手续费比例设置-转账###############################################
subject_title = "手续费比例设置-转账"
subject = "ConfigTransit"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'config_transits_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
##################################系统参数设置###############################################
subject_title = "系统参数设置"
subject = "IlConfig"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :default_action => 'il_configs_path',
  :subject => subject,
  :function => {
  :read =>{:title => "查看"} ,
  :create => {:title => "新建"},
  :update =>{:title =>"修改"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)

####################################理赔管理#########################################################
group_name = "理赔管理"
#################################理赔管理################################################
subject_title = "货损理赔"
subject = "GoodsException"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'goods_exceptions_path("search[state_ne]" => "identified")',
  :function => {
  #查看相关运单,其他机构发往当前用户机构的运单
  :read => {:title => "查看"},
  :destroy => {:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :show_authorize => {:title => "授权核销",:conditions =>"{:state => 'submited' }"},
  :show_claim => {:title => "理赔",:conditions =>"{:state => 'authorized'}"},
  :show_identify => {:title => "责任鉴定",:conditions =>"{:state => 'compensated'}"},
  :print => {:title => "打印"}
}
}
SystemFunction.create_by_hash(sf_hash)
#################################送货管理################################################
group_name = "送货管理"
subject_title = "送货员信息"
subject = "Sender"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'senders_path',
  :function => {
  #查看相关运单,其他机构发往当前用户机构的运单
  :read => {:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :update => {:title => "修改",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :destroy => {:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"}
}
}
SystemFunction.create_by_hash(sf_hash)
###############################送货登记##################################################
subject_title = "送货清单"
subject = "SendList"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'send_lists_path',
  :function => {
  #查看相关运单,其他机构发往当前用户机构的运单
  :read => {:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :destroy => {:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
###############################交票核销##################################################
subject_title = "交票清单"
subject = "SendListPost"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'new_send_list_post_path',
  :function => {
  :read => {:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :export => {:title => "导出"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)
###############################未交票统计##################################################
subject_title = "未交票统计"
subject = "SendListBack"
sf_hash = {
  :group_name => group_name,
  :subject_title => subject_title,
  :subject => subject,
  :default_action => 'send_list_backs_path',
  :function => {
  :read => {:title => "查看",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :create => {:title => "新建"},
  :destroy => {:title => "删除",:conditions =>"{:org_id => user.current_ability_org_ids }"},
  :export => {:title => "导出"}
}
}
SystemFunction.create_by_hash(sf_hash)
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
  :read => {:title => "查看"},
  :create => {:title => "新建"},
  :show_authorize => {:title => "核销",:conditions =>"{:state => 'submited'}"},
  :destroy => {:title => "删除"}
}
}
SystemFunction.create_by_hash(sf_hash)

#######################################################################################################3
#创建系统默认用户
#role = Role.new_with_default(:name => '管理员角色')
#role.role_system_function_operates.each { |r| r.is_select = true }
#role.save!

#管理员角色
#admin = User.new_with_roles(:username => 'system',:real_name => "管理员",:password => 'system',:is_admin => true)
#admin.user_orgs.each { |user_org| user_org.is_select = true }
#admin.user_roles.each {|user_role| user_role.is_select = true}
#admin.save!
