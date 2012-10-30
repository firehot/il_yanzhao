# -*- encoding : utf-8 -*-
#coding: utf-8
module OrgsHelper
  def orgs_for_select(include_summary = true)
    Org.where(:is_active => true,:is_summary => [include_summary,false]).all.map {|b| ["#{b.name}[#{b.py}]",b.id]}
  end

  def branches_for_select(include_summary = true)
    Branch.where(:is_active => true,:is_summary => [include_summary,false]).all.map {|b| ["#{b.name}[#{b.py}]",b.id]}
  end
  #中转中心
  #中转设为两个中转机构
  #中转部(分理处)
  #中转部(分公司)
  def yards_for_select
    get_current_yards.map {|b| ["#{b.name}[#{b.py}]",b.id]}
  end
  #根据当前登录用户的选择机构
  def current_org_for_select
    {current_user.default_org.name => current_user.default_org.id}
  end
  #除去当前机构的机构选择
  def branches_for_select_ex
    Branch.search(:is_active_eq => true,:id_ne => current_user.default_org.id).all.map {|b| ["#{b.name}[#{b.py}]",b.id]}
  end

  #当前登录用户可使用的的org
  def current_ability_orgs_for_select
    default_org = current_user.default_org
    ret = ActiveSupport::OrderedHash.new
    ret["#{default_org.name}[#{default_org.py}]"] = default_org.id
    default_org.children.each {|child_org|  ret["#{child_org.name}[#{child_org.py}]"] = child_org.id}
    ret
  end

  #当前登录用户可用之外的orgs
  #当前用户默认登录机构为分理处时,只显示分公司和中转部
  #当前登录用户是分公司时,只显示分理处/上级机构/中转部
  #show_summary 显示总公司,默认显示
  #show_bottom_blank 在列表最后显示空选项,默认不显示
  def exclude_current_ability_orgs_for_select(with_yard = false,show_summary = true,show_bottom_blank = false)
    #除去当前默认org和当前org的上级机构
    default_org = current_user.default_org
    ret_orgs = []
    if default_org.in_summary?
      default_org_id = default_org.id
      parent_id = current_user.default_org.parent_id
      exclude_ids =[current_user.default_org.id]
      exclude_ids << parent_id if parent_id.present?
      exclude_ids += Org.where(:parent_id => parent_id).collect(&:id) if parent_id.present?
      exclude_ids += Org.where(:parent_id => default_org_id).collect(&:id)
      yards_ids = get_current_yards.collect(&:id)
      exclude_ids -= yards_ids if with_yard
      exclude_ids.uniq!
      ret_orgs = Branch.search(:is_active_eq => true,:id_ni => exclude_ids).all
    else
      summary_org = Org.find_by_is_summary(true)
      ret_orgs.push(summary_org) if show_summary
      if summary_org.present?
        summary_children = Org.where(:parent_id => summary_org.id,:is_active => true)
        ret_orgs += summary_children
      end
      if with_yard
        ret_orgs += get_current_yards
      end
      ret_orgs.uniq!
      ret_orgs.compact!
    end
    ret_array = ret_orgs.map {|b| ["#{b.name}[#{b.py}]",b.id]}
    ret_array << ["(空)",""] if show_bottom_blank
    ret_array
  end
  #转换为json，在页面上使用
  def orgs_to_json_on_view
    Org.where(:is_active => true).all.to_json(:only => [:id,:name,:simp_name,:parent_id,:code,:carrying_fee_gte_on_insured_fee,:is_yard,:is_summary])
  end
  private
  #根据登录情况得到可以显示的中转货厂
  def get_current_yards
    yards = Org.where(:is_active => true,:is_yard => true)
    default_org = current_user.default_org
    if default_org.in_summary?
      #当前是总部的某个分理处登录的
      yards.delete_if {|yard| yard.parent_id == default_org.parent_id} if default_org.parent_id.present?
      #当前是总部登录的
      yards.delete_if {|yard| yard.parent_id == default_org.id} if default_org.parent_id.nil?
    else
      yards.delete_if {|yard| yard.parent_id.nil? }
    end
    yards
  end
  #得到修改权限
  def get_org_edit_permission_class
    ret_class =""
    ret_class="only_edit_lock_time" if can? :only_edit_lock_time,Org
    ret_class="" if can? :update_all,Org
    ret_class

  end
end

