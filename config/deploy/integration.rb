server "54.235.109.79", :web, :app, :db, :messenger, primary: true
set :branch, "development"
set :rails_env, 'staging'
set :local_app_url, 'http://localhost:3000/'
set :workers, {"*" => 1}