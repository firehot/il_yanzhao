#coding: utf-8
module ControllerMacros
  def login_admin
    before(:each) do
      @the_admin = Factory(:admin)
      sign_out :user
      sign_in @the_admin
      #设置权限
      #参考http://stackoverflow.com/questions/5018344/testing-views-that-use-cancan-and-devise-with-rspec
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      controller.stub(:current_ability) { @ability }
      @ability.can :manage,:all
    end
  end
end
