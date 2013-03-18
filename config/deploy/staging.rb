server "54.235.109.79", :web, :app, :db, :resque_worker, :resque_scheduler, primary: true
set :branch, "development"
set :rails_env, 'staging'