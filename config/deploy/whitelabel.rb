server "groupon.optyn.com", :web, :app, :db, :resque_worker, :resque_scheduler, :messenger, primary: true
set :branch, "white-label"
set :rails_env, 'whitelabel'
set :local_app_url, 'http://localhost:3000/'