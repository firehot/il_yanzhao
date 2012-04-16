# -*- encoding : utf-8 -*-
class SessionsController < Devise::SessionsController
  #GET /sessions/new_session_default
  def new_session_default
  end
  #PUT update_session_default
  def update_session_default
    current_user.update_attributes(:default_role_id => params[:cur_role_id],:default_org_id => params[:cur_org_id])
    redirect_to root_path
  end

  private
  # 参考https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in-out
  def after_sign_in_path_for(resource)
    user_root_path
  end
end
