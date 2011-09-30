#coding: utf-8
require 'spec_helper'

describe CarryingBillsController do
  login_admin
  render_views

  describe "GET index" do
    before(:each) do
      @computer_bill = Factory(:computer_bill)
    end

    it "assigns all computer_bills as @computer_bills" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    before(:each) do
      @computer_bill = Factory(:computer_bill)
    end


    it "should be success" do
      get :show, :id => @computer_bill
      response.should be_success
    end

    it "assigns the requested computer_bill as @computer_bill" do
      get :show, :id => @computer_bill
      response.should render_template('show')
    end
  end
  #测试外部查询运单服务
  describe "GET search_service_page" do
    it "should be success" do
      get :search_service_page
      response.should be_success
    end
  end
end
