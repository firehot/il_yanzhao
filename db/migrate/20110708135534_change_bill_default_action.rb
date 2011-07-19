class ChangeBillDefaultAction < ActiveRecord::Migration
  def self.up
    #修改运单录入的默认显示条件
    sf = SystemFunction.find_by_subject_title('运单录入')
    default_action = 'computer_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,"search[completed_eq]" => 0,"search[bill_date_eq]" =>Date.today,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")'
    sf.update_attributes(:default_action => default_action) if sf.present?
    sf = SystemFunction.find_by_subject_title('手工运单录入')
    default_action = 'hand_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,"search[completed_eq]" => 0,"search[bill_date_eq]" =>Date.today,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")'
    sf.update_attributes(:default_action => default_action) if sf.present?

    sf = SystemFunction.find_by_subject_title('中转运单录入')
    default_action = 'transit_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,"search[completed_eq]" => 0,"search[bill_date_eq]" =>Date.today,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")'
    sf.update_attributes(:default_action => default_action) if sf.present?


    sf = SystemFunction.find_by_subject_title('手工中转运单录入')
    default_action = 'hand_transit_bills_path("search[from_org_id_in]" => current_user.current_ability_org_ids,"search[completed_eq]" => 0,"search[bill_date_eq]" =>Date.today,:sort => "carrying_bills.bill_date desc,goods_no",:direction => "asc")'
    sf.update_attributes(:default_action => default_action) if sf.present?



  end

  def self.down
  end
end
