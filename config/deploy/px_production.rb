# -*- encoding : utf-8 -*-
#add bundler support
require 'bundler/capistrano'
set :application, "px_il_yanzhao_rails32"
set :repository,  "."
set :branch, "modify_insured_fee"
set :deploy_via, :copy
set :copy_cache, true
#
set :scm, :git
server "px.yanzhaowuliu.com",:app,:web,:db,:primary => true

set :user,"lmis"
set :use_sudo,false
default_run_options[:pty]=true

set :deploy_to,"~/app/px_il_yanzhao_rails32"

#set rvm support
set :rvm_ruby_string, '1.9.3@rails32_gemset'
#若rvm以user wide 安装,则rvm相关信息设置如下
#set :rvm_path, "~/.rvm"
#set :rvm_bin_path, "~/.rvm/bin"

#若rvm以system wide安装,则rvm设置如下
set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"

require "rvm/capistrano"

#set unicorn support
require 'capistrano-unicorn'
set :unicorn_bin,'r193_unicorn_rails'

after "deploy:symlink", :update_database_yml
desc "根据不同的staging修改数据库名称"
task :update_database_yml do
  replacements = { "il_yanzhao_r32_production" => "il_yanzhao_r32_production" }
  replacements.each_pair do |pattern, sub|
    run "sed -i 's/#{pattern}/#{sub}/' ~/app/il_yanzhao_rails32/current/config/database.yml"
  end
end
