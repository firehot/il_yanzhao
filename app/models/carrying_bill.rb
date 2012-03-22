# -*- encoding : utf-8 -*-
class CustomerCodeValidator < ActiveModel::EachValidator
  def validate_each(object,attribute,value)
    if value.present?
      from_customer = Customer.find_by_code_and_name_and_is_active(value,object.from_customer_name,true)
      if from_customer.blank?
        object.errors[attribute] <<(options[:message] || "客户编号与姓名不匹配" )
      else
        object.from_customer = from_customer
      end
    else #如果customer_code为null
      object.from_customer = nil
    end
  end
end
class CarryingBill < ActiveRecord::Base
  attr_protected :insured_rate,:original_carrying_fee,:original_goods_fee,:original_from_short_carrying_fee,:original_to_short_carrying_fee,:original_insured_amount,:original_insured_fee
  #营业额统计
  scope :turnover,select('from_org_id,IFNULL(to_org_id,transit_org_id) as to_org_id,sum(carrying_fee) as sum_carrying_fee,sum(goods_fee) as sum_goods_fee,sum(goods_num) as sum_goods_num,sum(1) as sum_bill_count').group('from_org_id,to_org_id')

  #今日收货
  scope :today_billed,lambda {|from_org_ids| select('pay_type,sum(carrying_fee) as carrying_fee,sum(goods_fee) as goods_fee,sum(goods_num) as goods_num,sum(1) as bill_count').where(:from_org_id => from_org_ids,:bill_date => Date.today).group(:pay_type)}
  #今日提货
  scope :today_deliveried,lambda {|to_org_ids| select('type,pay_type,sum(carrying_fee) as carrying_fee,sum(goods_fee)  as goods_fee,sum(goods_num) as goods_num,sum(1) as bill_count').where(:to_org_id => to_org_ids,:state =>:deliveried).search(:deliver_info_deliver_date_eq => Date.today).group('type,pay_type')}
  #今日提款(仅指现金提款)
  scope :today_paid,lambda {|from_org_ids| select('pay_type,sum(carrying_fee) as carrying_fee,sum(goods_fee) as goods_fee,sum(goods_num) as goods_num,sum(k_hand_fee) as k_hand_fee,sum(transit_hand_fee) as transit_hand_fee,sum(1) as bill_count').where(:from_org_id => from_org_ids,:state =>:paid).search(:from_customer_id_is_null => 1,:pay_info_bill_date_eq => Date.today).group('pay_type')}
  #最近票据(5张)
  scope :recent_bills,lambda {|from_org_ids| where(:from_org_id => from_org_ids).order("created_at DESC").limit(5)}

  #待提货票据(不包括中转票据)
  scope :ready_delivery,lambda {|to_org_ids| select('sum(1) as bill_count').where(:to_org_id => to_org_ids,:state => :distributed)}
  #待提款票据
  scope :ready_pay,lambda {|from_org_ids| search(:from_customer_id_is_null => 1).where(:from_org_id => from_org_ids,:state => :payment_listed).select('sum(goods_fee) as goods_fee,sum(1) as bill_count')}

  #货款收入情况
  scope :sum_goods_fee_in,lambda {|from_org_ids,date_from,date_to| select('from_org_id,sum(goods_fee) as sum_goods_fee_in').where(:from_org_id => from_org_ids,:state => ["refunded_confirmed","payment_listed","paid","posted"],:updated_at => date_from..date_to).group('from_org_id')}
  #货款支出情况
  scope :sum_goods_fee_out,lambda {|from_org_ids,date_from,date_to| select('from_org_id,sum(goods_fee) as sum_goods_fee_out').where(:from_org_id => from_org_ids,:state => ["paid",'posted'] ,:updated_at => date_from..date_to).group('from_org_id')}

  scope :with_association,:include => [:from_org,:to_org,:transit_org,:send_list_line,:user]


  #before_validation :set_customer
  #保存成功后,设置原始费用
  before_create :set_original_fee
  #计算手续费
  before_save :cal_hand_fee

  belongs_to :user
  belongs_to :from_org,:class_name => "Org"
  belongs_to :transit_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  belongs_to :area

  belongs_to :from_customer,:class_name => "Customer"

  #票据对应的装车清单
  belongs_to :load_list
  belongs_to :distribution_list

  belongs_to :deliver_info
  belongs_to :settlement
  belongs_to :refound
  belongs_to :payment_list
  belongs_to :pay_info
  belongs_to :post_info

  belongs_to :transit_info
  belongs_to :transit_deliver_info

  #于退货单来讲,所对应的原始票据,未退货的票据为空
  belongs_to :original_bill,:class_name => "CarryingBill"
  #对于原始单据来讲,有一个对应的退货单据
  has_one :return_bill,:foreign_key => "original_bill_id",:class_name => "ReturnBill"


  #该运单对应的送货信息
  #当前活动的只能有一条
  has_one :send_list_line
  #有多条装车记录
  has_many :act_load_list_lines

  #验证运费支付方式为从货款扣时,货款必须大于运费,否则不能保存
  validate :check_k_carrying_fee

  validates :bill_no,:goods_no,:uniqueness => true
  #运单编号为7位数字
  validates_format_of :bill_no,:with => /^(TH)*\d{7}$/
  validates_presence_of :bill_date,:pay_type,:from_customer_name,:to_customer_name,:from_org_id,:goods_info
  validates_numericality_of :insured_amount,:insured_rate,:insured_fee,:goods_num
  validates_numericality_of :goods_fee,:from_short_carrying_fee,:to_short_carrying_fee,:less_than => 100000
  validates :customer_code,:customer_code => true
  #初始创建运单时,运费必须大于0
  validates :carrying_fee,:numericality => {:greater_than => 0},:on => :create
  #修改运单时,运费大于或等于0
  validates :carrying_fee,:numericality => {:greater_than_or_equal_to => 0},:on => :update

  #定义state_machine
  #已开票
  #已装车
  #已发出
  #已到货
  #已分发(分货处理)
  #已中转(针对中转票据)
  #已提货
  #已日结(结算员已交款)
  #已返款
  #已到帐
  #已提款
  #已退货
  state_machine :initial => :billed do
    #运单处理完成后,设置completed标志
    #存在以下几种情况；
    #1 现金付回执付运单,没有代收货款,提货后,运单已经完成
    #2 现金提款运单,提款日接后(posted),运单完成
    #3 转账提款运单,提款后(paid),运单完成
    #4 运单退货后,自动完成
    #5 退货单返款清单确认后,自动完成
    #在这几种情况下,自动设置completed标志

    after_transition :on => :standard_process,:deliveried => :settlemented,:do => :set_completed_settlemented
    after_transition :on => :standard_process,:paid => :posted,:do => :set_completed_posted
    after_transition :on => :standard_process,:payment_listed => :paid,:do => :set_completed_paid
    after_transition :on => :return,any => :returned,:do => :set_completed_returned
    after_transition :on => :standard_process,:refunded => :refunded_confirmed,:do => :set_completed_refunded_confirmed

    #正常运单处理流程(包括机打运单/手工运单/退货单据)
    event :standard_process do
      transition(:billed => :loaded,   #装车
                 :loaded => :shipped,#发货
                 :shipped => :reached,#到货
                 :deliveried => :settlemented,#日结清单
                 :settlemented => :refunded,#返款
                 :refunded => :refunded_confirmed,#返款确认
                 :refunded_confirmed => :payment_listed,#支付清单
                 :payment_listed => :paid,#货款已支付
                 :paid => :posted) #过帐结束

      #普通运单到货后有分发操作,中转运单不存在分发操作
      transition :reached => :distributed,:distributed => :deliveried,:if => lambda {|bill| bill.transit_org_id.blank?}

      #中转运单处理流程
      transition :reached => :transited,:transited => :deliveried,:if => lambda {|bill| bill.transit_org_id.present?}

      #TODO 现金付运费,不存在代收货款的运单,提货后处理流程如何?
    end

    #退货单处理流程
    #退货处理中,根据当前票据状态产生退货票据
    #after_transition :on => :return,[:reached,:distributed] => :returned,:do => :generate_return_bill
    event :return do
      #货物已发出,进行退货操作,会自动生成一张相反的单据
      transition [:reached,:distributed] => :returned
    end
    #运单重置处理
    after_transition :on => :reset,any => :billed,:do => :reset_bill
    event :reset do
      transition any => :billed
    end
    #中转部结算交款后,直接进行交款确认,无需再进行返款
    event :direct_refunded_confirmed do
      transition :settlemented => :refunded_confirmed
    end

    #运单作废操作
    after_transition :on => :invalidate,:billed => :invalided,:do => :set_completed_invalid
    event :invalidate do
      transition :billed => :invalided
    end

    #根据运单状态进行验证操作
    state :loaded,:shipped,:reached do
      validates_presence_of :load_list_id
    end
    state :transited do
      validates_presence_of :transit_info_id
    end

    state :distributed do
      validates_presence_of :distribution_list_id
    end
    state :deliveried do
      validates_presence_of :deliver_info_id, :unless => :transit_bill?
    end
    state :deliveried do
      validates_presence_of :transit_deliver_info_id, :if => :transit_bill?
    end

    state :settlemented do
      validates_presence_of :settlement_id
    end
    state :refunded,:refunded_confirmed do
      validates_presence_of :refound_id
    end
    state :payment_listed do
      validates_presence_of :payment_list_id
    end
    state :paid do
      validates_presence_of :pay_info_id
    end
    state :posted do
      validates_presence_of :post_info_id
    end
    end

    #短途运费状态声明
    state_machine :from_short_fee_state,:initial => :draft,:namespace => :from_short_fee do
      #发货地短途运费核销
      event :write_off  do
        transition :draft => :offed
      end
    end
    #短途运费状态声明
    state_machine :to_short_fee_state,:initial => :draft,:namespace => :to_short_fee do
      #发货地短途运费核销
      event :write_off  do
        transition :draft => :offed
      end
    end

    #字段默认值
    default_value_for :bill_date do
      Date.today
    end
    default_value_for :goods_num,1
    default_value_for :insured_rate,0.003 #IlConfig.insured_rate
    default_value_for :from_short_carrying_fee,0
    default_value_for :to_short_carrying_fee,0
    default_value_for :insured_amount,0

    PAY_TYPE_CASH = "CA"    #现金付
    PAY_TYPE_TH = "TH"      #提货付
    PAY_TYPE_RETURN = "RE"  #回执付
    PAY_TYPE_K_GOODSFEE = "KG"  #自货款扣除
    #付款方式描述
    def self.pay_types
      ret = ActiveSupport::OrderedHash.new
      ret["提货付"] = PAY_TYPE_TH
      ret["现金付"] = PAY_TYPE_CASH
      ret["回执付"] = PAY_TYPE_RETURN
      ret["货款扣运费"] = PAY_TYPE_K_GOODSFEE
      ret
    end

    #付款方式描述
    def pay_type_des
      pay_type_des = ""
      CarryingBill.pay_types.each {|des,code| pay_type_des = des if code == self.pay_type }
      pay_type_des
    end
    #2012-03-01添加
    #从to_customer_phone 和 to_customer_mobile中取可用的手机号
    #NOTE 实际录单时,录单人员可能将手机号录入到固定电话一栏中去
    def sms_mobile
      the_mobile = nil
      the_mobile = to_customer_phone if self.to_customer_phone.present? and self.to_customer_phone.size == 11
      the_mobile = to_customer_mobile if self.to_customer_mobile.present? and self.to_customer_mobile.size == 11
      the_mobile
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

    #以千分数表示的保价费
    def insured_rate_disp
      self.insured_rate*1000
    end
    def insured_rate_disp=(rate)
    end
    #送货状态
    def send_state
      send_state = "draft"
      send_state = self.send_list_line.state if self.send_list_line.present?
      send_state
    end
    #提付运费,付款方式为提货付时,等于运费,其他为0
    def carrying_fee_th
      ret = 0
      ret = self.carrying_fee if self.pay_type == CarryingBill::PAY_TYPE_TH
      ret
    end
    #提货保价费
    def insured_fee_th
      ret = 0
      ret = self.insured_fee if self.pay_type == CarryingBill::PAY_TYPE_TH
      ret
    end

    #扣运费,运费支付方式为从货款扣除时等于运费,否则为0
    def k_carrying_fee
      ret = 0
      ret = self.carrying_fee if self.pay_type == CarryingBill::PAY_TYPE_K_GOODSFEE
      ret
    end
    #实提货款 原货款 - 扣运费 - 扣手续费
    def act_pay_fee
      ret = self.goods_fee - self.k_hand_fee - self.k_carrying_fee - self.transit_hand_fee
    end
    #代收运费解释：原票运费支付方式为提货付的，代收运费=原运费—中转运费；
    #原票运费支付方式为现金付的，代收运费为0
    def agent_carrying_fee
      ret = 0
      ret = self.carrying_fee_th - self.transit_carrying_fee if self.pay_type == CarryingBill::PAY_TYPE_TH
      ret
    end

    #得到提货应收金额
    def th_amount
      amount = self.carrying_fee_th - self.transit_hand_fee - self.transit_carrying_fee + self.goods_fee
      amount += self.insured_fee if self.pay_type == CarryingBill::PAY_TYPE_TH
      amount
    end
    #运费总计
    def carrying_fee_total
      carrying_fee + insured_fee
    end
    #提付运费合计
    #运费支付方式=提货付 提付运费合计 = 运费 + 保价费
    #其他支付方式 提副运费合计 = 0
    def carrying_fee_th_total
      ret = 0
      ret = carrying_fee + insured_fee if pay_type.eql?(CarryingBill::PAY_TYPE_TH)
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
        "pay_type"=> PAY_TYPE_TH,
        "goods_fee"=> 0,
        "from_short_carrying_fee" => self.to_short_carrying_fee*2,
        "to_short_carrying_fee" => self.from_short_carrying_fee*2,
        "carrying_fee"=> (pay_type == PAY_TYPE_CASH ? self.carrying_fee : 2*self.carrying_fee),
        "note"=> "原运单票据号:#{self.bill_no},货号:#{self.goods_no},运费:#{self.carrying_fee},代收货款;#{self.goods_fee}"
      }
      #如果是中转票据,则将中转站与始发站调换
      override_attr.merge!("from_org_id"=> self.transit_org_id,"to_org_id"=> self.from_org_id) unless self.transit_org_id.blank?
      return_attr = self.attributes.merge(override_attr)
      return_attr.delete("goods_no")
      self.build_return_bill(return_attr)
    end
    #重写to_s方法
    def to_s
      "#{self.bill_no}/#{self.goods_no}"
    end
    #导出方法
    def self.to_csv(search_obj,options = {},with_bom_header = true)
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
    def self.search_sum(search)
      sum_info = {
        #:count => search.count,
        #:sum_carrying_fee => search.relation.sum(:carrying_fee),
        #现金付运费合计
        :sum_carrying_fee_cash => search.where(:pay_type => CarryingBill::PAY_TYPE_CASH).sum(:carrying_fee),
        #提货付运费合计
        :sum_carrying_fee_th => search.where(:pay_type => CarryingBill::PAY_TYPE_TH).sum(:carrying_fee),
        #回执付运费合计
        :sum_carrying_fee_re => search.where(:pay_type => CarryingBill::PAY_TYPE_RETURN).sum(:carrying_fee),
        #自货款扣除运费合计
        :sum_k_carrying_fee => search.where(:pay_type => CarryingBill::PAY_TYPE_K_GOODSFEE).sum(:carrying_fee),
        #提付保价费合计
        :sum_insured_fee_th => search.where(:pay_type => CarryingBill::PAY_TYPE_TH).sum(:insured_fee)
      }
      sum_info_tmp = search.select('sum(1) as count,sum(carrying_fee) as sum_carrying_fee,sum(k_hand_fee) as sum_k_hand_fee,sum(goods_fee) as sum_goods_fee,sum(insured_fee) as sum_insured_fee,sum(transit_carrying_fee) as sum_transit_carrying_fee,sum(transit_hand_fee) as sum_transit_hand_fee,sum(from_short_carrying_fee) as sum_from_short_carrying_fee,sum(to_short_carrying_fee) as sum_to_short_carrying_fee,sum(goods_num) as sum_goods_num').first.attributes
      sum_info_tmp.each do |key,value|
        sum_info_tmp.delete(key)
        sum_info_tmp[key.to_sym] = value.blank? ? 0 : value
      end
      sum_info.merge!(sum_info_tmp)
      #运费合计 运费+保价费
      sum_info[:sum_carrying_fee_total] = sum_info[:sum_carrying_fee] + sum_info[:sum_insured_fee]
      #提付运费合计
      #实提货款合计
      sum_info[:sum_act_pay_fee] = sum_info[:sum_goods_fee] - sum_info[:sum_k_carrying_fee] - sum_info[:sum_k_hand_fee] - sum_info[:sum_transit_hand_fee]
      sum_info[:sum_agent_carrying_fee] =0
      #提付运费大于零时,才有代收运费,否则代收运费为0
      sum_info[:sum_agent_carrying_fee] = sum_info[:sum_carrying_fee_th] - sum_info[:sum_transit_carrying_fee] if sum_info[:sum_carrying_fee_th] > 0
      sum_info[:sum_th_amount] = sum_info[:sum_carrying_fee_th] - sum_info[:sum_transit_carrying_fee] -  sum_info[:sum_transit_hand_fee] + sum_info[:sum_goods_fee]
      sum_info[:sum_carrying_fee_th_total] = sum_info[:sum_carrying_fee_th] + sum_info[:sum_insured_fee_th]
      sum_info
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
      t_state = "未提款" if self.refunded? or self.refunded_confirmed? or self.payment_listed?
      t_state = "已退货" if self.returned?
      t_state = "已作废" if self.invalided?
    end

    protected
    #导出选项
    def self.export_options
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
    private
    def set_customer
      if customer_code.blank?
        self.from_customer = nil
      elsif Vip.exists?(:code => customer_code,:name => from_customer_name,:is_active => true)
        self.from_customer = Vip.where(:is_active => true).find_by_code(customer_code)
      end
    end
    #计算手续费
    def cal_hand_fee
      if self.goods_fee_cash?
        self.k_hand_fee = ConfigCash.cal_hand_fee(:goods_fee => self.goods_fee,:from_org_id => self.from_org_id,:to_org_id => self.to_org_id)
      else
        self.k_hand_fee = ConfigTransit.cal_hand_fee(:goods_fee => self.goods_fee,:from_org_id => self.from_org_id,:to_org_id => self.to_org_id)
      end
      self.k_hand_fee
    end
    #保存票据成功后,设置原始费用
    def set_original_fee
      self.original_carrying_fee = self.carrying_fee
      self.original_from_short_carrying_fee = self.from_short_carrying_fee
      self.original_to_short_carrying_fee = self.to_short_carrying_fee
      self.original_goods_fee = self.goods_fee
      self.original_insured_amount = self.insured_amount
      self.original_insured_fee = self.insured_fee
    end
    #重置票据
    def reset_bill
      self.update_attributes(:load_list_id => nil,:distribution_list_id => nil,:deliver_info_id => nil,:settlement_id => nil,:refound_id => nil,:payment_list_id => nil,:pay_info_id => nil,:post_info_id => nil,:transit_info_id => nil,:completed => false)
    end

    #根据运单不同情况设置completed标志
    #现金付/回执付/无代收货款,自动置结束标记
    def set_completed_settlemented
      self.update_attributes(:completed => true) if [PAY_TYPE_RETURN,PAY_TYPE_CASH].include?(self.pay_type) and self.goods_fee == 0
    end
    #现金提款
    def set_completed_posted
      self.update_attributes(:completed => true) if self.goods_fee_cash?
    end
    #转账提款
    def set_completed_paid
      self.update_attributes(:completed => true) unless self.goods_fee_cash?
    end
    #退货后,原始单据直接标志为完成
    def set_completed_returned
      self.update_attributes(:completed => true)
    end
    #提货付运费且货款为0,收款清单确认后,自动完成
    def set_completed_refunded_confirmed
      self.update_attributes(:completed => true) if self.pay_type.eql? PAY_TYPE_TH and self.goods_fee == 0
    end
    #运单作废后,设标志为完成
    def set_completed_invalid
      self.update_attributes(:completed => true)
    end

    #验证中转费用
    def check_transit_fee
      errors.add(:transit_carrying_fee,"中转运费不能大于原运费.") if transit_carrying_fee > carrying_fee
      errors.add(:transit_hand_fee,"中转手续费不能大于原运费.") if transit_hand_fee > carrying_fee
    end
    #运费支付方式为从货款扣时,货款必须大于运费
    def check_k_carrying_fee
      errors.add(:k_carrying_fee,"货款金额必须大于运费金额.") if pay_type.eql?(PAY_TYPE_K_GOODSFEE) and goods_fee <= carrying_fee
    end
    end

