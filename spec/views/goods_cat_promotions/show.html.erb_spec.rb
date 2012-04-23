require 'spec_helper'

describe "goods_cat_promotions/show" do
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

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/false/)
  end
end
