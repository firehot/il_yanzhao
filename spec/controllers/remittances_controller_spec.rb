require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe RemittancesController do

  def mock_remittance(stubs={})
    @mock_remittance ||= mock_model(Remittance, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all remittances as @remittances" do
      Remittance.stub(:all) { [mock_remittance] }
      get :index
      assigns(:remittances).should eq([mock_remittance])
    end
  end

  describe "GET show" do
    it "assigns the requested remittance as @remittance" do
      Remittance.stub(:find).with("37") { mock_remittance }
      get :show, :id => "37"
      assigns(:remittance).should be(mock_remittance)
    end
  end

  describe "GET new" do
    it "assigns a new remittance as @remittance" do
      Remittance.stub(:new) { mock_remittance }
      get :new
      assigns(:remittance).should be(mock_remittance)
    end
  end

  describe "GET edit" do
    it "assigns the requested remittance as @remittance" do
      Remittance.stub(:find).with("37") { mock_remittance }
      get :edit, :id => "37"
      assigns(:remittance).should be(mock_remittance)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created remittance as @remittance" do
        Remittance.stub(:new).with({'these' => 'params'}) { mock_remittance(:save => true) }
        post :create, :remittance => {'these' => 'params'}
        assigns(:remittance).should be(mock_remittance)
      end

      it "redirects to the created remittance" do
        Remittance.stub(:new) { mock_remittance(:save => true) }
        post :create, :remittance => {}
        response.should redirect_to(remittance_url(mock_remittance))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved remittance as @remittance" do
        Remittance.stub(:new).with({'these' => 'params'}) { mock_remittance(:save => false) }
        post :create, :remittance => {'these' => 'params'}
        assigns(:remittance).should be(mock_remittance)
      end

      it "re-renders the 'new' template" do
        Remittance.stub(:new) { mock_remittance(:save => false) }
        post :create, :remittance => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested remittance" do
        Remittance.stub(:find).with("37") { mock_remittance }
        mock_remittance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :remittance => {'these' => 'params'}
      end

      it "assigns the requested remittance as @remittance" do
        Remittance.stub(:find) { mock_remittance(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:remittance).should be(mock_remittance)
      end

      it "redirects to the remittance" do
        Remittance.stub(:find) { mock_remittance(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(remittance_url(mock_remittance))
      end
    end

    describe "with invalid params" do
      it "assigns the remittance as @remittance" do
        Remittance.stub(:find) { mock_remittance(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:remittance).should be(mock_remittance)
      end

      it "re-renders the 'edit' template" do
        Remittance.stub(:find) { mock_remittance(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested remittance" do
      Remittance.stub(:find).with("37") { mock_remittance }
      mock_remittance.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the remittances list" do
      Remittance.stub(:find) { mock_remittance }
      delete :destroy, :id => "1"
      response.should redirect_to(remittances_url)
    end
  end

end
