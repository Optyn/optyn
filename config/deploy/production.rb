server "ec2-23-23-158-217.compute-1.amazonaws.com", :web, :app, :db, :resque_worker, :resque_scheduler, primary: true
set :branch, "master"
set :rails_env, 'production'