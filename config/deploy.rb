# -*- encoding : utf-8 -*-
#add bundler support
require 'bundler/capistrano'
set :application, "il_yanzhao_rails32"
set :repository,  "."
set :branch, "upgrade_to_rails32"
#set :local_repository, "file://f:/il_yanzhao/.git"
set :deploy_via, :copy
set :copy_cache, true
#
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
server "zz.yanzhaowuliu.com",:app,:web,:db,:primary => true

set :user,"root"
set :use_sudo,false
default_run_options[:pty]=true

#set rvm support
set :rvm_ruby_string, '1.9.3@rails32_gemset'
set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"
require "rvm/capistrano"
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
  desc "Generate assets "
  task :generate_assets, :roles => :web do
    run "bundle exec rake assets:precompile"
  end
  desc "create cache dir"
  task :create_cache_dir,:roles => :web do
    run "cd #{deploy_to}/current/tmp && mkdir cache"
    run "cd #{deploy_to}/current && chmod 777 tmp -R"
    #run "cd #{deploy_to}/current/tmp && chmod 777 cache"
  end
  after "deploy:create_symlink","rvm:trust_rvmrc"

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
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
