# -*- encoding : utf-8 -*-
# carrying_bill的方法定义和class_methods定义
module CarryingBillExtend
  module CarryingBill
    def self.included(base)
      base.extend ClassMethods
    end
    #付款方式描述
    def pay_type_des
      pay_type_des = ""
      PayType.pay_types.each {|des,code| pay_type_des = des if code == self.pay_type }
      pay_type_des
    end
    def from_org_name
      ""
      self.from_org.name unless self.from_org.nil?
    end
    def transit_org_name
      ""
      self.transit_org.name unless self.transit_org.nil?
    end

    def to_org_name
      ""
      self.to_org.name unless self.to_org.nil?
    end
    #发货人卡号
    def from_customer_bank_card
      return '' if self.from_customer.blank?
      self.from_customer.bank_card
    end
    #发货人编号
    def from_customer_code
      return '' if self.from_customer.blank?
      self.from_customer.code
    end
    #代收货款转账银行
    def from_customer_bank_name
      return '' if self.from_customer.blank?
      self.from_customer.bank.name
    end
    #提付运费,付款方式为提货付时,等于运费,其他为0
    def carrying_fee_th
      ret = 0
      ret = self.carrying_fee if self.pay_type == PayType::PAY_TYPE_TH
      ret
    end
    #提货保价费
    def insured_fee_th
      ret = 0
      ret = self.insured_fee if self.pay_type == PayType::PAY_TYPE_TH
      ret
    end
    #ADD at 2012-9-23
    #提货发货短途费,运费支付方式为提货付时,等于发货短途费,其他为0
    def from_short_carrying_fee_th
      ret = 0
      ret = self.from_short_carrying_fee if self.pay_type == PayType::PAY_TYPE_TH
      ret
    end
    #ADD at 2012-9-23
    #提货到货短途费,运费支付方式为提货付时,等于到货短途费,其他为0
    def to_short_carrying_fee_th
      ret = 0
      ret = self.to_short_carrying_fee if self.pay_type == PayType::PAY_TYPE_TH
      ret
    end


    #扣运费,运费支付方式为从货款扣除时等于运费,否则为0
    def k_carrying_fee
      ret = 0
      ret = self.carrying_fee if self.pay_type == PayType::PAY_TYPE_K_GOODSFEE
      ret
    end
    #2012-9-23
    #扣保险费,运费支付为[从货款扣]时等与保险费,否则为0
    def k_insured_fee
      ret = 0
      ret = self.insured_fee if self.pay_type == PayType::PAY_TYPE_K_GOODSFEE
      ret
    end
    #2012-9-23
    #扣发货短途,运费支付为[从货款扣]时等于发货短途费,否则为0
    def k_from_short_carrying_fee
      ret = 0
      ret = self.from_short_carrying_fee if self.pay_type == PayType::PAY_TYPE_K_GOODSFEE
      ret
    end
    #2012-9-23
    #扣到货短途,运费支付为[从货款扣]时等于到货短途费,否则为0
    def k_to_short_carrying_fee
      ret = 0
      ret = self.to_short_carrying_fee if self.pay_type == PayType::PAY_TYPE_K_GOODSFEE
      ret
    end
    #Added at 2012-9-23
    #扣运费合计 = 扣运费 + 扣保险费 + 扣到货短途 + 扣发货短途
    def k_carrying_fee_total
      self.k_carrying_fee + self.k_insured_fee + self.k_from_short_carrying_fee + self.k_to_short_carrying_fee
    end

    #实提货款 原货款 - 扣运费 - 扣手续费
    def act_pay_fee
      ret = self.goods_fee - self.k_hand_fee - self.k_carrying_fee - self.transit_hand_fee - self.k_insured_fee - self.k_from_short_carrying_fee - self.k_to_short_carrying_fee
    end
    #代收运费解释：原票运费支付方式为提货付的，代收运费=原运费—中转运费；
    #原票运费支付方式为现金付的，代收运费为0
    def agent_carrying_fee
      ret = 0
      ret = self.carrying_fee_th - self.transit_carrying_fee if self.pay_type == PayType::PAY_TYPE_TH
      ret
    end

    #得到提货应收金额
    #NOTE 2012-09-23
    #运费支付方式为提货付时: 提货应收 = 提付运费 - 中转手续费 - 中转运费 - 中转运费 + 货款 + 保险费 + 发货短途 + 收货短途
    def th_amount
      amount = self.carrying_fee_th - self.transit_hand_fee - self.transit_carrying_fee + self.goods_fee
      amount += self.insured_fee + self.from_short_carrying_fee + self.to_short_carrying_fee if self.pay_type == PayType::PAY_TYPE_TH
      amount
    end

    #运费总计
    #NOTE  指的是运费 + 保险费 + 发货短途 + 到货短途,与付款方式无关
    #2012-9-23 发货短途运费和到货短途运费也计入合计运费中去
    #NOTE 运费合计 = 运费 + 保险费 + 发货地短途 + 到货地短途

    def carrying_fee_total
      carrying_fee + insured_fee + from_short_carrying_fee + to_short_carrying_fee
    end
    #提付运费合计
    #运费支付方式=提货付 提付运费合计 = 运费 + 保价费
    #其他支付方式 提副运费合计 = 0
    #2012-9-23 发货短途运费和到货短途运费也计入合计运费中去
    #付款方式为现金付时:提付运费合计 = 0
    #付款方式为提货付时:提付运费合计 = 运费 + 保险费 + 发货地短途 + 到货地短途
    def carrying_fee_th_total
      ret = 0
      ret = carrying_fee + insured_fee + from_short_carrying_fee + to_short_carrying_fee if pay_type.eql?(PayType::PAY_TYPE_TH)
      ret
    end

    #代收货款支付方式,无客户编号时,为现金支付
    def goods_fee_cash?
      self.from_customer.blank?
    end
    #是中转运单还是其他运单
    def transit_bill?
      ["TransitBill","HandTransitBill"].include? self.type
    end
    #滞留天数
    def stranded_days
      ((Date.today.end_of_day - self.bill_date.beginning_of_day) /1.day).to_i
    end
    #剩余未装车数量
    def rest_goods_num
      ret = goods_num
      ret = goods_num - self.act_load_list_lines.sum(:load_num) unless self.act_load_list_lines.blank?
      ret
    end

    #定义customer_code虚拟属性
    def customer_code
      @customer_code || self.from_customer.try(:code)
    end
    def customer_code=(customer_code)
      @customer_code = customer_code
    end
    #转换为打印使用的json
    def to_print_json
      self.to_json(:except =>[:created_at,:updated_at],:methods => [:area,:from_org,:transit_org,:to_org,:user,:customer_code,:th_amount,:carrying_fee_total,:carrying_fee_th,:pay_type_des,:type])
    end
    #根据货号计算排序号
    def sort_seq
      "#{self.bill_date.strftime('%y%m%d')}#{self.from_org.simp_name}#{self.transit_org.present? ? self.transit_org.simp_name : self.to_org.simp_name}#{"%04d" % self.goods_no[/\d{1,4}-/][/\d{1,5}/].to_i}"
    end
    #支付清单排序
    def payment_list_sort_seq
      "#{self.transit_org.present? ? self.transit_org.simp_name : self.to_org.simp_name}#{self.bill_date.strftime('%y%m%d')}#{self.from_org.simp_name}#{"%04d" % self.goods_no[/\d{1,4}-/][/\d{1,5}/].to_i}"
    end
    #票据费用是否修改
    def fee_changed?
      !original_goods_fee.eql?(goods_fee) or !original_carrying_fee.eql?(carrying_fee ) or !original_insured_amount.eql?(insured_amount) or !original_insured_fee.eql?(insured_fee) or !original_from_short_carrying_fee.eql?(from_short_carrying_fee)  or !original_to_short_carrying_fee.eql?(to_short_carrying_fee)
    end

    #票据状态,目前系统内部状态较多,根据客户要求修改为有限的几个状态
    def translate_state
      t_state = "已开票" if self.billed?
      t_state = "已发货" if self.loaded? or self.shipped? or self.reached? or self.distributed? or self.transited?
      t_state = "已提货" if self.deliveried? or self.settlemented?
      t_state = "已提货未提款" if self.refunded? or self.refunded_confirmed? or self.payment_listed?
      t_state = "已取款" if self.paid? or self.posted?
      t_state = "已退货" if self.returned?
      t_state = "已作废" if self.invalided?
      t_state
    end
    #是否已保存短途信息
    def from_short_fee_saved?
      self.short_fee_info_lines.joins(:short_fee_info).where("short_fee_infos.org_id = ?",self.from_org_id).exists?
    end
    def to_short_fee_saved?
      self.short_fee_info_lines.joins(:short_fee_info).where("short_fee_infos.org_id = ?",self.to_org_id).exists?
    end

    #机打运单编号从4000000开始
    #生成票据编号
    def generate_bill_no
      self.bill_no = BillNo.gen_bill_no
    end
    def generate_goods_no
      #货号规则
      #6位年月日+始发地市+到达地市+始发组织机构代码（如返程货则为到达地组织机构代码）+序列号+“-”+件数
      #新建单据/修改发货地/到货地/中转地 重新生成货号
      if self.new_record?  or (self.changes[:from_org_id].present? or self.changes[:to_org_id].present? or self.changes[:transit_org_id].present?)
        self.goods_no = GoodsNo.gen_goods_no(self)
      end
    end
    #生成退货单据
    #录入原运单编号后回车，可显示原票信息退货信息：
    #退货运单编号为TH原运单编号，
    #货号在确认时由电脑按始发货规则自动编，
    #结算单位、组织机构默认为当前操作员所属，
    #发货站、到达站、发货人、收货人、电话、手机为原票信息颠倒，
    #运费支付方式默认提货付，
    #代收货款默认为0，代收货款支付方式默认为现金支付，
    #货物信息、保价内容按原票显示，
    #运费如原票支付方式为现金付的则自动显示为单倍，其他支付方式的显示为双倍运费，
    #备注自动显示原票代收货款及货号。
    #如中转货退回，则中转站还显示原中转站。
    #确认后，原票状态应显示为已退且在未提货中取消，在本地发货时增加该票

    def generate_return_bill
      override_attr = {
        "bill_no" => "TH#{self.bill_no}",
        "bill_date"=> Date.today,
        "from_org_id"=> self.to_org_id,
        "to_org_id"=> self.from_org_id,
        "from_customer_name"=> self.to_customer_name,
        "from_customer_phone"=> self.to_customer_phone,
        "to_customer_name"=> self.from_customer_name,
        "to_customer_phone"=> self.from_customer_phone,
        "from_customer_id"=> nil,
        "to_customer_id"=> nil,
        "pay_type"=> PayType::PAY_TYPE_TH,
        "goods_fee"=> 0,
        "insured_fee" => (pay_type == PayType::PAY_TYPE_CASH ? self.insured_fee : self.insured_fee*2),
        "from_short_carrying_fee" => (pay_type == PayType::PAY_TYPE_CASH ? self.to_short_carrying_fee : self.to_short_carrying_fee*2),
        "to_short_carrying_fee" => (pay_type == PayType::PAY_TYPE_CASH ? self.from_short_carrying_fee : self.from_short_carrying_fee*2),
        "carrying_fee"=> (pay_type == PayType::PAY_TYPE_CASH ? self.carrying_fee : 2*self.carrying_fee),
        "note"=> "原运单票据号:#{self.bill_no},货号:#{self.goods_no},运费:#{self.carrying_fee},代收货款;#{self.goods_fee}"
      }
      #如果是中转票据,则将中转站与始发站调换
      override_attr.merge!("from_org_id"=> self.transit_org_id,"to_org_id"=> self.from_org_id) unless self.transit_org_id.blank?
      return_attr = self.attributes.merge(override_attr)
      delete_attrs = %w[goods_no original_carrying_fee original_goods_fee original_from_short_carrying_fee insured_rate original_insured_amount type original_insured_fee id original_to_short_carrying_fee original_carrying_fee]
      return_attr.delete_if { |key,value| delete_attrs.include?(key)}
      self.build_return_bill(return_attr)
    end

    #重写to_s方法
    def to_s
      "#{self.bill_no}/#{self.goods_no}"
    end

    module ClassMethods
      #导出短信文本
      def export_sms_txt_for_arrive(ids=[])
        #去除固定电话和空号
        sms_bills = self.find(ids).find_all {|bill| bill.sms_mobile_for_arrive.present? }
        no_mobile_sms_bills = self.find(ids).find_all {|bill| bill.sms_mobile_for_arrive.blank? }
        group_sms_bills = sms_bills.group_by(&:sms_mobile_for_arrive)
        #分别合计货物件数/运费合计/货款合计
        sms_text = ''
        group_sms_bills.each do |key,bills|
          goods_num = bills.to_a.sum(&:goods_num)
          goods_nos = []
          bills.each do |the_bill|
            goods_nos << the_bill.goods_no[6..-1]
          end
          goods_fee = bills.to_a.sum(&:th_amount).to_i
          sms_text += Settings.notice_arrive.sms_batch % [key,bills[0].to_org.try(:name),goods_nos.join(" "),goods_fee,bills[0].to_org.try(:location),bills[0].to_org.try(:phone)]
        end
        sms_text +="===============================以下运单无手机号===============================================\r\n"
        no_mobile_sms_bills.each do |bill|
          goods_no = bill.goods_no[6..-1]
          sms_text += Settings.notice_arrive.sms_batch % [bill.try(:phone_or_mobile_for_arrive),bill.to_org.try(:name),goods_no,bill.th_amount,bill.to_org.try(:location),bill.to_org.try(:phone)]
        end
        sms_text
      end
      #导出方法
      def to_csv(search_obj,options = {},with_bom_header = true)
        options = self.export_options if options.blank?
        sum_info = self.search_sum(search_obj)
        #导出明细信息
        ret = search_obj.where('1=1').with_association.export_csv(options,with_bom_header)
        #导出合计信息
        sum_array =["合计:#{sum_info[:count]}票"]
        options[:methods].each do |method_name|
          sum_value = sum_info["sum_#{method_name}".to_sym]
          if sum_value.present? and sum_value.is_a?(Numeric)
            sum_array << sum_value
          else
            sum_array << ""
          end
        end
        ret = ret + sum_array.export_line_csv
        ret
      end
      #得到票据合计信息
      def search_sum(search)
        sum_info = {
          #:count => search.count,
          #:sum_carrying_fee => search.relation.sum(:carrying_fee),
          #现金付运费合计
          :sum_carrying_fee_cash => search.where(:pay_type => PayType::PAY_TYPE_CASH).sum(:carrying_fee),
          #提货付运费合计
          :sum_carrying_fee_th => search.where(:pay_type => PayType::PAY_TYPE_TH).sum(:carrying_fee),
          #回执付运费合计
          :sum_carrying_fee_re => search.where(:pay_type => PayType::PAY_TYPE_RETURN).sum(:carrying_fee),
          #自货款扣除运费合计
          :sum_k_carrying_fee => search.where(:pay_type => PayType::PAY_TYPE_K_GOODSFEE).sum(:carrying_fee),
          #自货款扣保险费
          :sum_k_insured_fee => search.where(:pay_type => PayType::PAY_TYPE_K_GOODSFEE).sum(:insured_fee),
          #自货款扣发货短途
          :sum_k_from_short_carrying_fee => search.where(:pay_type => PayType::PAY_TYPE_K_GOODSFEE).sum(:from_short_carrying_fee),
          #自货款扣到货短途
          :sum_k_to_short_carrying_fee => search.where(:pay_type => PayType::PAY_TYPE_K_GOODSFEE).sum(:to_short_carrying_fee),
          #提付保价费合计
          :sum_insured_fee_th => search.where(:pay_type => PayType::PAY_TYPE_TH).sum(:insured_fee),
          #2012-9-23 付款方式为提货付时,合计发货短途运费及到货短途运费
          :sum_from_short_carrying_fee_th => search.where(:pay_type => PayType::PAY_TYPE_TH).sum(:from_short_carrying_fee),
          :sum_to_short_carrying_fee_th => search.where(:pay_type => PayType::PAY_TYPE_TH).sum(:to_short_carrying_fee)
        }
        sum_info_tmp = search.select('sum(1) as sum_count,sum(carrying_fee) as sum_carrying_fee,sum(k_hand_fee) as sum_k_hand_fee,sum(goods_fee) as sum_goods_fee,sum(insured_fee) as sum_insured_fee,sum(transit_carrying_fee) as sum_transit_carrying_fee,sum(transit_hand_fee) as sum_transit_hand_fee,sum(from_short_carrying_fee) as sum_from_short_carrying_fee,sum(to_short_carrying_fee) as sum_to_short_carrying_fee,sum(goods_num) as sum_goods_num').first.attributes

        #将hash key转换为symbol
        sum_info.merge!(Hash[sum_info_tmp.map{ |k, v| [k.to_sym, (v.blank? ? 0 : v)] }])
        #运费合计 运费+保险费+发货短途 + 到货短途
        sum_info[:sum_carrying_fee_total] = sum_info[:sum_carrying_fee] + sum_info[:sum_insured_fee] + sum_info[:sum_from_short_carrying_fee] + sum_info[:sum_to_short_carrying_fee]

        #从货款扣运费合计
        sum_info[:sum_k_carrying_fee_total] = sum_info[:sum_k_carrying_fee] + sum_info[:sum_k_insured_fee] + sum_info[:sum_k_from_short_carrying_fee] + sum_info[:sum_k_to_short_carrying_fee]

        #实提货款合计
        sum_info[:sum_act_pay_fee] = sum_info[:sum_goods_fee] - sum_info[:sum_k_hand_fee] - sum_info[:sum_transit_hand_fee] - sum_info[:sum_k_carrying_fee_total]
        sum_info[:sum_agent_carrying_fee] =0
        #提付运费大于零时,才有代收运费,否则代收运费为0
        sum_info[:sum_agent_carrying_fee] = sum_info[:sum_carrying_fee_th] - sum_info[:sum_transit_carrying_fee] if sum_info[:sum_carrying_fee_th] > 0
        #提付运费合计
        sum_info[:sum_carrying_fee_th_total] = sum_info[:sum_carrying_fee_th] + sum_info[:sum_insured_fee_th] + sum_info[:sum_from_short_carrying_fee_th] + sum_info[:sum_to_short_carrying_fee_th]
        #提货应收合计
        sum_info[:sum_th_amount] = sum_info[:sum_carrying_fee_th_total] - sum_info[:sum_transit_carrying_fee] -  sum_info[:sum_transit_hand_fee] + sum_info[:sum_goods_fee]
        sum_info
      end
      protected
      #导出选项
      def export_options
        {
          :only => [],
          :methods => [
            :bill_date,:bill_no,:goods_no,:from_customer_name,:from_customer_phone,:from_customer_mobile,
            :to_customer_name,:to_customer_phone,:to_customer_mobile,:from_org_name,
            :transit_org_name,:to_org_name,:pay_type_des,:from_short_carrying_fee,:to_short_carrying_fee,
            :carrying_fee,:carrying_fee_th,:k_carrying_fee,:k_hand_fee,:goods_fee,:insured_fee,:transit_carrying_fee,
            :transit_hand_fee,:act_pay_fee,:agent_carrying_fee,:th_amount,:goods_num,:note,:human_state_name
          ]}
      end
    end
  end
end
