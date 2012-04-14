# -*- encoding : utf-8 -*-
#运单编号生成器
class BillNo < ActiveRecord::Base
  def self.gen_bill_no
    bill_no = BillNo.find_or_create_by_id(1)
    BillNo.increment_counter(:bill_count,1)
    bill_no.reload.bill_count
  end
end

