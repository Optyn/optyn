server "ec2-23-22-29-198.compute-1.amazonaws.com", :web, :app, :db, :messenger, primary: true
set :branch, "development"
set :rails_env, 'staging'
set :local_app_url, 'http://localhost:3000/'
set :workers, {"*" => 1}
