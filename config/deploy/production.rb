server "ec2-54-227-243-108.compute-1.amazonaws.com", :web, :app, :db, :messenger, primary: true
set :branch, "master"
set :rails_env, 'production'
set :local_app_url, 'http://localhost:3000/'
set :workers, {"general_queue" => 1, "import_queue" => 1, "message_queue" => 2, "payment_queue" => 1}