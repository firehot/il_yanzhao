#coding: utf-8
class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "您无权操作此功能!"
    redirect_to "/403.html"
  end
end
