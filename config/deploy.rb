require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'rvm/capistrano'

set :default_stage, "production"
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
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "gaurav_personal_rsa")]

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
set :rvm_ruby_string, "ruby-1.9.3-p385@optyn"
set :rvm_type, :user
set :deploy_via, :remote_cache

after "deploy", "deploy:cleanup" # keep only the last 5 releases

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
#

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
before "deploy", "deploy:check_revision"
after "deploy:setup", "deploy:setup_nginx_config"
before 'deploy:assets:precompile', 'deploy:create_symlinks'
after 'deploy:update_code', 'deploy:migrate'
after "deploy:update_code", "deploy:cleanup"

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
		sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
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

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run %Q{cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:clean && RAILS_ENV=#{rails_env} && bundle exec rake assets:precompile}
    end
  end
end