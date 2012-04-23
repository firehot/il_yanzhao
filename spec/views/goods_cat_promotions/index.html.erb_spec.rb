require 'spec_helper'

describe "goods_cat_promotions/index" do
  before(:each) do
    assign(:goods_cat_promotions, [
      stub_model(GoodsCatPromotion,
        :goods_cat => nil,
        :from_fee => "",
        :from_fee => "",
        :to_fee => "",
        :to_fee => "",
        :promotion_rate => "",
        :promotion_rate => "",
        :is_active => false
      ),
      stub_model(GoodsCatPromotion,
        :goods_cat => nil,
        :from_fee => "",
        :from_fee => "",
        :to_fee => "",
        :to_fee => "",
        :promotion_rate => "",
        :promotion_rate => "",
        :is_active => false
      )
    ])
  end

  it "renders a list of goods_cat_promotions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
