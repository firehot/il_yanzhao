#add bundler support
require 'bundler/capistrano'
set :application, "il_yanzhao"
#set :repository,  "git://github.com/chengdh/il_yanzhao.git"
set :repository, "."
set :local_repository, "file:///media//WORK/il_yanzhao/.git"
#set :local_repository, "file://f:/il_yanzhao/.git"
set :deploy_via, :copy
set :copy_cache, true
#
#set :repository,  "file:///media//WORK/il_yanzhao/.git"

set :scm, :git
set :branch,:master
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
server "116.255.186.172",:app,:web,:db,:primary => true

set :user,"root"
set :use_sudo,false
default_run_options[:pty]=true

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  desc "Generate assets with Jammit"
  task :generate_assets, :roles => :web do
    run "cd #{deploy_to}/current && bundle exec jammit"
  end
  after "deploy:symlink", "deploy:generate_assets"
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  #自定义系统维护界面
  namespace :web do
    task :disable do
      on_rollback { delete "#{shared_path}/system/maintenance.html" }
      maintenance = render("layouts/maintenance",:deadline => ENV['UNTIL'],:reason => ENV['REASON'])
      put maintenance, "#{shared_path}/system/maintenance.html",:mode => 0644
    end
  end

  private
  #渲染给定的模板
  def render(layout, options = {})
    viewer = ActionView::Base.new(Rails::Configuration.new.view_path, options)
    viewer.render layout
  end

end
