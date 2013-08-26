server "54.235.109.79", :web, :app, :db, :messenger, primary: true
# :resque_worker, :resque_scheduler,
set :branch, "development"
set :rails_env, 'staging'
set :local_app_url, 'http://localhost:3000/'