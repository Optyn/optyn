server "ec2-54-211-197-135.compute-1.amazonaws.com", :web, :app, :db, :messenger, :resque_worker, :resque_schedular, primary: true
set :branch, "whitelabel-development"
set :rails_env, 'staging'
set :local_app_url, 'http://localhost:3000/'