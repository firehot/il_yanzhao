require 'spec_helper'

describe "goods_cat_promotions/edit" do
  before(:each) do
    @goods_cat_promotion = assign(:goods_cat_promotion, stub_model(GoodsCatPromotion,
      :goods_cat => nil,
      :from_fee => "",
      :from_fee => "",
      :to_fee => "",
      :to_fee => "",
      :promotion_rate => "",
      :promotion_rate => "",
      :is_active => false
    ))
  end

  it "renders the edit goods_cat_promotion form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => goods_cat_promotions_path(@goods_cat_promotion), :method => "post" do
      assert_select "input#goods_cat_promotion_goods_cat", :name => "goods_cat_promotion[goods_cat]"
      assert_select "input#goods_cat_promotion_from_fee", :name => "goods_cat_promotion[from_fee]"
      assert_select "input#goods_cat_promotion_from_fee", :name => "goods_cat_promotion[from_fee]"
      assert_select "input#goods_cat_promotion_to_fee", :name => "goods_cat_promotion[to_fee]"
      assert_select "input#goods_cat_promotion_to_fee", :name => "goods_cat_promotion[to_fee]"
      assert_select "input#goods_cat_promotion_promotion_rate", :name => "goods_cat_promotion[promotion_rate]"
      assert_select "input#goods_cat_promotion_promotion_rate", :name => "goods_cat_promotion[promotion_rate]"
      assert_select "input#goods_cat_promotion_is_active", :name => "goods_cat_promotion[is_active]"
    end
  end
end
