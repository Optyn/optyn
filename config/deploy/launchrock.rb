server "launchrock.optyn.com", :web, :app, :db, :resque_worker, :resque_scheduler, :messenger, primary: true
set :branch, "launchrock"
set :rails_env, 'launchrock'
set :local_app_url, 'http://localhost:3000/'