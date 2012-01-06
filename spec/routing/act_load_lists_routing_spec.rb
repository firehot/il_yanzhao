require "spec_helper"

describe ActLoadListsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/act_load_lists" }.should route_to(:controller => "act_load_lists", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/act_load_lists/1" }.should route_to(:controller => "act_load_lists", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/act_load_lists/1/edit" }.should route_to(:controller => "act_load_lists", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/act_load_lists" }.should route_to(:controller => "act_load_lists", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/act_load_lists/1" }.should route_to(:controller => "act_load_lists", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/act_load_lists/1" }.should route_to(:controller => "act_load_lists", :action => "destroy", :id => "1")
    end

  end
end
