class AddFunctionRptGoodsFeeInout < ActiveRecord::Migration
  def self.up
    ##############################代收货款收入/支出统计#############################################
    group_name = "查询统计"
    subject_title = "代收货款收入/支出统计"
    subject = "CarryingBill"
    sf_hash = {
      :group_name => group_name,
      :subject_title => subject_title,
      :default_action => 'sum_goods_fee_inout_carrying_bills_path',
      :subject => subject,
      :function => {
      :sum_goods_fee_inout =>{:title =>"代收货款收入/支出统计"}
    }
    }
    SystemFunction.create_by_hash(sf_hash)
  end

  def self.down
  end
end
