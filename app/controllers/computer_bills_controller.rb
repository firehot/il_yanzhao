#coding: utf-8
class ComputerBillsController < CarryingBillsController
  skip_authorize_resource :only => [:edit,:update]
end
