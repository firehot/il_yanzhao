#coding: utf-8
class HandBillsController < CarryingBillsController
  skip_authorize_resource :only => [:edit,:update]
end
