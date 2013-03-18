require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'rvm/capistrano'
require "#{File.dirname(__FILE__)}/../lib/recipes/redis"
require "capistrano-resque"

set :default_stage, "staging"
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

#set the reque workers add other queues here...
set :workers, { "devise_queue" => 1 }


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
#

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
before "deploy", "deploy:check_revision"
after "deploy:update_code", "deploy:web:disable"
after "deploy:setup", "deploy:setup_nginx_config"
before 'deploy:assets:precompile', 'deploy:create_symlinks'
after 'deploy:update_code', 'deploy:migrate'
after "deploy:update_code", "deploy:cleanup"
after "deploy:restart", "resque:start"
after "deploy:restart", "deploy:web:enable"
after "deploy", "deploy:cleanup"


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
		puts "*" * 50
		puts "Running symlinks"
		run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
	end

	desc 'Start unicorn'
	task :start, :roles => :app, :except => { :no_release => true } do
		puts "Starting Unicorn"
		run "cd #{current_path}; bundle exec unicorn -E #{rails_env} -c config/unicorn.rb -D"
	end

	desc 'Stop unicorn'
	task :stop, :roles => :app, :except => { :no_release => true } do
		run "kill -9 `lsof -t -i:3000`" rescue nil
	end

	desc 'Restart unicorn'
	task :restart, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    stop
    start
  end

  desc "Migrating the database"
  task :migrate, :roles => :db do
  	run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate --trace"
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
end