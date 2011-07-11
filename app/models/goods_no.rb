#coding: utf-8
#货号生成器
class GoodsNo < ActiveRecord::Base
  belongs_to :from_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  #生成新的货号
  def self.gen_goods_no(bill)
    from_org_id = bill.from_org_id
    to_org_id = bill.transit_org_id.present? ? bill.transit_org_id : bill.to_org_id
    goods_no = GoodsNo.find_or_create_by_from_org_id_and_to_org_id_and_gen_date(from_org_id,to_org_id,bill.bill_date)
    #删除以往数据
    GoodsNo.destroy_all(["from_org_id = ? AND to_org_id = ? AND gen_date < ? ",from_org_id,to_org_id,bill.bill_date])
    GoodsNo.increment_counter(:bill_count,goods_no.id)

    "#{bill.bill_date.strftime('%y%m%d')}#{bill.from_org.simp_name}#{bill.transit_org.present? ? bill.transit_org.simp_name : bill.to_org.simp_name}#{goods_no.reload.bill_count}-#{bill.goods_num}"
  end
end
