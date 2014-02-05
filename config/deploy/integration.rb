server "ec2-54-235-109-79.compute-1.amazonaws.com", :web, :app, :db, :messenger, primary: true
set :branch, "development"
set :rails_env, 'integration'
set :local_app_url, 'http://localhost:3000/'
