#coding: utf-8
#货物分类费用设置
class GoodsCatFeeConfig < ActiveRecord::Base
  belongs_to :from_org,:class_name => "Org"
  belongs_to :to_org,:class_name => "Org"
  has_many :goods_cat_fee_config_lines,:dependent => :destroy
  has_many :goods_cats,:through => :goods_cat_fee_config_lines
  validates :from_org,:to_org,:presence => true
  validates :to_org_id,:uniqueness => {:scope => :from_org_id}
  accepts_nested_attributes_for :goods_cat_fee_config_lines
  #构造运费设置明细
  def all_group_lines
    #NOTE 此处只支持2级分类
    GoodsCat.search(:is_active_eq => true,:parent_id_is_not_null => true).order("order_by ASC").each do |child_cat|
        self.goods_cat_fee_config_lines.build(:goods_cat => child_cat) unless self.goods_cats.include?(child_cat)
    end
    @group_lines ||= self.goods_cat_fee_config_lines.sort_by {|line| line.goods_cat.order_by }.group_by {|line| line.goods_cat.parent}
    @group_lines
  end
end
