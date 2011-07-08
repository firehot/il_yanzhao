#系统启动时,缓存相关数据
class AppCache
  cache = Rails.cache
  #获取机打运单的数量
  #机打运单从4000000开始
  bill_count = 4000000 + CarryingBill.where(:type => ["ComputerBill","TransitBill"]).count
  cache.write('bill_count',bill_count)

  #生成票号
  def self.gen_bill_no
    cur_count = Rails.cache.read('bill_count');
    Rails.cache.write('bill_count',cur_count + 1)
    "%07d" % cur_count
  end
  #缓存指定日期/发货地/到货地(中转地)的运单数量
  #bill 给定的参照bill
  def self.get_seq(bill)
    #先查找当日是否已缓存
    seq = 0
    seq_key = ""
    if bill.transit_org.present?
      seq_key = "#{bill.bill_date.strftime('%y%m%d')}_#{bill.from_org_id}_#{bill.transit_org_id}_transit_seq"
      seq = Rails.cache.read(seq_key)
      #如果当日没有缓存
      if seq_transit.blank?
        seq = CarryingBill.where(:bill_date => bill.bill_date,:from_org_id => bill.from_org_id,:transit_org_id => bill.to_org_id).count + 1
      else
        seq +=1
      end
    else
      seq_key = "#{bill.bill_date.strftime('%y%m%d')}_#{bill.from_org_id}_#{bill.to_org_id}_seq"
      seq = Rails.cache.read(seq_key)
      #如果当日没有缓存
      if seq.blank?
        seq = CarryingBill.where(:bill_date => bill.bill_date,:from_org_id => bill.from_org_id,:to_org_id => bill.to_org_id).count + 1
      else
        seq +=1
      end
    end
    #删除以往缓存
    Rails.cache.delete_matched(/[^#{bill.bill_date.strftime('%y%m%d')}]\w+seq$/)
    Rails.cache.write(seq_key,seq)
    seq
  end
  #生成货号
  def self.gen_goods_no(bill)
    goods_no = "#{bill.bill_date.strftime('%y%m%d')}#{bill.from_org.simp_name}#{bill.transit_org.present? ? bill.transit_org.simp_name : bill.to_org.simp_name}#{get_seq(bill)}-#{bill.goods_num}"
  end
end
