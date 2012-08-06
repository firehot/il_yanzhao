# -*- encoding : utf-8 -*-
#add bundler support
require 'bundler/capistrano'
set :application, "il_yanzhao_rails32"
set :repository,  "."
set :branch, "upgrade_to_rails32"
set :deploy_via, :copy
set :copy_cache, true
#
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
#server "zz.yanzhaowuliu.com",:app,:web,:db,:primary => true
server "192.168.0.202",:app,:web,:db,:primary => true

set :user,"lmis"
set :use_sudo,false
default_run_options[:pty]=true

set :deploy_to,"~/app/il_yanzhao_rails32"

#set rvm support
set :rvm_ruby_string, '1.9.3@rails32_gemset'
set :rvm_path, "~/.rvm"
set :rvm_bin_path, "~/.rvm/bin"
require "rvm/capistrano"

#set unicorn support
require 'capistrano-unicorn'
set :unicorn_bin,'r193_unicorn_rails'
=begin
set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ree-1.8.7-2011.03/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => 'ree 1.8.7',
  'GEM_HOME'     => '/usr/local/rvm/gems/ree-1.8.7-2011.01@rails3_gemset',
  'GEM_PATH'     => '/usr/local/rvm/gems/ree-1.8.7-2011.03:/usr/local/rvm/gems/ree-1.8.7-2011.01@rails3_gemset',
  'BUNDLE_PATH'     => '/usr/local/rvm/gems/ree-1.8.7-2011.03'
}
=end
# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts
namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end
namespace :deploy do
  after "deploy:create_symlink","rvm:trust_rvmrc"
  #自定义系统维护界面
  namespace :web do
    task :disable do
      on_rollback { delete "#{shared_path}/system/maintenance.html" }
      require 'rubygems'
      require 'erb'
      template = File.read("./app/views/layouts/maintenance.html.erb")
      erb = ERB.new(template)
      put erb.result, "#{shared_path}/system/maintenance.html",:mode => 0644
    end
  end
end
