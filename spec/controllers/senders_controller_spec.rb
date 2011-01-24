require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe SendersController do

  def mock_sender(stubs={})
    @mock_sender ||= mock_model(Sender, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all senders as @senders" do
      Sender.stub(:all) { [mock_sender] }
      get :index
      assigns(:senders).should eq([mock_sender])
    end
  end

  describe "GET show" do
    it "assigns the requested sender as @sender" do
      Sender.stub(:find).with("37") { mock_sender }
      get :show, :id => "37"
      assigns(:sender).should be(mock_sender)
    end
  end

  describe "GET new" do
    it "assigns a new sender as @sender" do
      Sender.stub(:new) { mock_sender }
      get :new
      assigns(:sender).should be(mock_sender)
    end
  end

  describe "GET edit" do
    it "assigns the requested sender as @sender" do
      Sender.stub(:find).with("37") { mock_sender }
      get :edit, :id => "37"
      assigns(:sender).should be(mock_sender)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created sender as @sender" do
        Sender.stub(:new).with({'these' => 'params'}) { mock_sender(:save => true) }
        post :create, :sender => {'these' => 'params'}
        assigns(:sender).should be(mock_sender)
      end

      it "redirects to the created sender" do
        Sender.stub(:new) { mock_sender(:save => true) }
        post :create, :sender => {}
        response.should redirect_to(sender_url(mock_sender))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sender as @sender" do
        Sender.stub(:new).with({'these' => 'params'}) { mock_sender(:save => false) }
        post :create, :sender => {'these' => 'params'}
        assigns(:sender).should be(mock_sender)
      end

      it "re-renders the 'new' template" do
        Sender.stub(:new) { mock_sender(:save => false) }
        post :create, :sender => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sender" do
        Sender.stub(:find).with("37") { mock_sender }
        mock_sender.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :sender => {'these' => 'params'}
      end

      it "assigns the requested sender as @sender" do
        Sender.stub(:find) { mock_sender(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:sender).should be(mock_sender)
      end

      it "redirects to the sender" do
        Sender.stub(:find) { mock_sender(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(sender_url(mock_sender))
      end
    end

    describe "with invalid params" do
      it "assigns the sender as @sender" do
        Sender.stub(:find) { mock_sender(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:sender).should be(mock_sender)
      end

      it "re-renders the 'edit' template" do
        Sender.stub(:find) { mock_sender(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested sender" do
      Sender.stub(:find).with("37") { mock_sender }
      mock_sender.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the senders list" do
      Sender.stub(:find) { mock_sender }
      delete :destroy, :id => "1"
      response.should redirect_to(senders_url)
    end
  end

end