server "ec2-204-236-233-14.compute-1.amazonaws.com", :web, :app, :db, :resque_worker, :resque_scheduler, :messenger, primary: true
set :branch, "master"
set :rails_env, 'production'
set :local_app_url, 'http://localhost:3000/'