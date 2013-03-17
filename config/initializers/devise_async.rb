# Devise::Async.backend = :resque
Devise::Async.setup do |config|
  config.backend = :resque
  config.queue   = :devise_queue
end