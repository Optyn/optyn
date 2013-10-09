require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'rvm/capistrano'
require 'capistrano-unicorn'
require "capistrano-resque"
require "#{File.dirname(__FILE__)}/../lib/recipes/redis"



set :default_stage, "staging"
set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { default_stage }
require "whenever/capistrano"
set :application, "optyn"
set :user, "deploy"
set :deploy_to, "/srv/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:Optyn/optyn.git"
set :keep_releases, 3
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
set :rvm_ruby_string, "ruby-1.9.3-p385@optyn"
set :rvm_type, :user
set :deploy_via, :remote_cache

#set the lock file while deploying so that messagecenter tasks and deployments don't run parallel
set :lock_file_path, "#{shared_path}/pids"
set :lock_file_name, 'deployment.pid'

if "production" == rails_env
  set :workers, {"general_queue" => 1, "import_queue" => 1, "message_queue" => 2, "payment_queue" => 1}
else
  set :workers, {"*" => 1}
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
#

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
before "deploy", "deploy:check_revision"
after "deploy:setup", "deploy:setup_nginx_config"
before 'deploy:update_code', 'deploy:messenger:lock'
before 'deploy:assets:precompile', 'deploy:create_symlinks'
after 'deploy:update_code', 'deploy:migrate'
# after 'deploy:update_code', 'deploy:sitemap'
after "deploy:update_code", "deploy:cleanup"
after "deploy:finalize_update", "deploy:web:disable"
before "whenever:update_crontab", "whenever:clear_crontab"
after 'deploy:restart', 'unicorn:stop','unicorn:start'
# after "deploy:restart", "resque:restart"
# after "deploy:restart", "deploy:list:workers"

# after "deploy:restart", "deploy:maint:flush_cache"
after "deploy:restart", "deploy:web:enable"
after "deploy:restart", "deploy:messenger:unlock"
after "deploy", "deploy:cleanup"
#after "deploy:create_symlink", "whenever"


namespace "whenever" do
  task :clear_crontab do
    # run "cd #{fetch(:previous_release)} && bundle exec whenever --clear-crontab --set environment=#{rails_env} --user #{user} #{application}"
    # run "cd #{fetch(:current_release)} && bundle exec whenever --clear-crontab --set environment=#{rails_env} --user #{user} #{application}"
  end

  task :update_crontab do
    # run "cd #{release_path} &&  bundle exec whenever --update-crontab --set environment=#{rails_env} #{application}"
  end
end

namespace :deploy do
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    branch_rev = `git rev-parse HEAD`
    head_rev = `git rev-parse origin/#{branch || master}`

    unless branch_rev == head_rev
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  task :setup_nginx_config, roles: :app do
    unless "production" == rails_env
      sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    end
  end

  desc 'Copy database.yml from shared to current folder'
  task :create_symlinks, :roles => :app, :except => {:no_release => true} do
    puts "Running symlinks"
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
  end

  desc "Migrating the database"
  task :migrate, :roles => :db do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate --trace"
  end

  desc "Generate the site map"
  task :sitemap, :roles => :app do
    puts "Generating the sitemap"
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake sitemap:clean && RAILS_ENV=#{rails_env} bundle exec rake sitemap:refresh"
  end

  namespace :assets do
  	task :precompile, :roles => :web, :except => { :no_release => true } do
  		 run %Q{cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:clean && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile --trace}
  	end
  end

  #show hide maintenance page
  namespace :web do
    task :disable, :roles => :web, :except => { :no_release => true } do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason = ENV['REASON']
      deadline = ENV['UNTIL']

      template = File.read(File.join(File.dirname(__FILE__), "deploy",
                                     "maintenance.html.erb"))
      result = ERB.new(template).result(binding)

      put result, "#{shared_path}/system/maintenance.html", :mode => 0644
    end

    task :enable, :roles => :web, :except => { :no_release => true } do
      run "rm #{shared_path}/system/maintenance.html"
    end
  end

  namespace :maint do
    task :flush_cache, :roles => :db, :only => { :primary => true } do
      puts '  * flushing cache on the app servers...'
      send(run_method, "/usr/bin/curl -u optyn:9p5yn123 #{local_app_url}cache/flush") # &> /dev/null")
    end
  end

  namespace :messenger do
    #task create a lock file.
    task :lock, :roles => :messenger, :only => {:primary => true} do
      msg = %Q{
      ACTION:deployment
      PID:#{Process.pid}
      MESSAGE:'Running Deployment'
      TIME:#{Time.now}
      }
      put msg, "#{lock_file_path}/#{lock_file_name}", :mode => 0644
    end

    #task delete lock file.
    task :unlock, :roles => :messenger, :only => {:primary => true} do
      run "rm #{shared_path}/pids/#{lock_file_name}"
    end
  end

  namespace :list do
    desc "List all the resque workers"
    task :workers do
      puts "* Listing all the resque workers"
      run "ps aux |grep resque"
    end
  end  
end

        require './config/boot'
        # require 'airbrake/capistrano'
