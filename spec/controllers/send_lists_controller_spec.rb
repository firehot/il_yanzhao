#coding: utf-8
require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe SendListsController do
  login_admin
  render_views

  before(:each) do
    @send_list = Factory(:send_list)
  end


  describe "GET index" do
    it "assigns all send_lists as @send_lists" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do

    it "should be success" do
      get :show, :id => @send_list
      response.should be_success
    end

    it "assigns the requested send_list as @send_list" do
      get :show, :id => @send_list
      response.should render_template('show')
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
      @attr = Factory.build(:send_list).attributes
      @bill = Factory(:computer_bill)
    end
    describe "success" do
      it "能够成功保存送货清单信息" do
        lambda do
          post :create, :send_list => @attr,:bill_ids => [@bill.id]
        end.should change(SendList,:count).by(1)
      end

      it "redirects to the created send_list" do
        post :create, :send_list => @attr,:bill_ids => [@bill.id]
        response.should redirect_to(send_list_path(assigns(:send_list)))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        post :create, :send_list => {},:bill_ids => [@bill.id]
        response.should render_template("new")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested send_list" do
      lambda do
        delete :destroy, :id => @send_list
      end.should change(SendList,:count).by(-1)
    end

    it "redirects to the send_lists list" do
      delete :destroy, :id => @send_list
      response.should redirect_to(send_lists_url)
    end
  end
  describe "GET search" do
    it "should be success" do
      get :search
      response.should be_success
    end
    it "should render 'search'" do
      get :search
      response.should render_template('search')
    end
  end
end
