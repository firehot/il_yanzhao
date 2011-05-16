#coding: utf-8
require 'spec_helper'


# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe GoodsExceptionsController do
  login_admin
  render_views

  before(:each) do
    @goods_exception = Factory(:goods_exception)
  end


  describe "GET index" do
    it "assigns all goods_exceptions as @goods_exceptions" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    it "should be success" do
      get :show, :id => @goods_exception
      response.should be_success
    end

    it "assigns the requested goods_exception as @goods_exception" do
      get :show, :id => @goods_exception
      response.should render_template('show')
    end
  end

  describe "GET show_authorize" do
    it "should be _success" do
      get :show_authorize ,:id => Factory(:goods_exception)
      response.should be_success
    end
  end

  describe "GET show_claim" do
    it "should be _success" do
      get :show_claim ,:id => Factory(:goods_exception)
      response.should be_success
    end
  end

  describe "GET show_identify" do
    it "should be _success" do
      get :show_identify ,:id => Factory(:goods_exception)
      response.should be_success
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
      @attr = Factory.build(:goods_exception).attributes
    end
    describe "success" do
      it "能够成功保存票据信息" do
        lambda do
          post :create, :goods_exception => @attr
        end.should change(GoodsException,:count).by(1)
      end

      it "redirects to the created goods_exception" do
        post :create, :goods_exception => @attr
        response.should redirect_to(goods_exception_path(assigns(:goods_exception)))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        post :create, :goods_exception => {}
        response.should render_template("new")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested goods_exception" do
      lambda do
        delete :destroy, :id => @goods_exception
      end.should change(GoodsException,:count).by(-1)
    end

    it "redirects to the goods_exceptions list" do
      delete :destroy, :id => @goods_exception
      response.should redirect_to(goods_exceptions_url)
    end
  end
end
