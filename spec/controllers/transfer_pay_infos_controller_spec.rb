require 'spec_helper'

describe TransferPayInfosController do
  render_views

  describe "GET index" do
    it "should be success" do
      Factory(:transfer_pay_info_with_bills)
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    it "assigns the requested transfer_pay_info as @transfer_pay_info" do
      p_list = Factory(:transfer_pay_info_with_bills)
      get :show, :id => p_list
      assigns(:transfer_pay_info).should == p_list
    end
  end

  describe "GET new" do
    it "should be success" do
      get :new
      response.should be_success
    end
  end

  describe "POST create" do
    before(:each) do
      @computer_bill = Factory(:computer_bill_payment_listed)
    end

    describe "with valid params" do
      it "success create transfer_pay_info" do
        lambda do
          post :create,:transfer_pay_info => {:org_id => Factory(:zz),:customer_name => "customer_name"},:bill_ids => [@computer_bill.id]
        end.should change(TransferPayInfo,:count).by(1)
      end

      it "redirects to the created transfer_pay_info" do
        post :create,:transfer_pay_info => {:org_id => Factory(:zz),:customer_name => "customer_name"},:bill_ids => [@computer_bill.id]
        response.should redirect_to(assigns(:transfer_pay_info))
      end
    end

    describe "with invalid params" do
      it "re-render the new 'template'" do
        post :create, :transfer_pay_info => {}
        response.should render_template('new')
      end
    end
  end
end