# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)
# Initialize the rails application
IlYanzhao::Application.initialize!
ActiveRecord::Base.include_root_in_json = false
#Encoding.default_external = Encoding::UTF_8
#Encoding.default_internal = Encoding::UTF_8
