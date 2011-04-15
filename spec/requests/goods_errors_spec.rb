require 'spec_helper'

describe "GoodsException2s" do
  describe "GET /goods_errors" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get goods_errors_path
      response.status.should be(200)
    end
  end
end
