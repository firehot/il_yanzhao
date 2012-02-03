#coding: utf-8
#转账客户
class Vip <  Customer

  attr_protected :code
  belongs_to :bank
  belongs_to :org
  belongs_to :config_transit
  validates :name,:id_number,:org_id,:bank_id,:mobile,:presence => true
  validates :code,:uniqueness => true
  validates :bank_card,:length => {:maximum => 30}
  default_scope :order => "code ASC",:include => [:bank,:org]

  before_create :set_code

  #导出
  def self.to_csv(search_obj)
    search_obj.all.export_csv(self.export_options)
  end
  def self.export_options
    {
      :only => [],
      :methods => [:org,:name,:code,:phone,:mobile,:address,:bank,:bank_card]
    }
  end

  private
  def set_code
    self.code = self.bank.code + self.org.code + get_sequence
  end
  #根据机构获取当前机构已有的VIP客户数量
  def get_sequence
    max_code = Vip.maximum(:code,:conditions => {:org_id => self.org_id,:bank_id => self.bank_id})
    next_seq = 1
    next_seq = max_code[/\d{4}$/].to_i + 1 if max_code.present?

    se = "%04d" % next_seq
  end
end
