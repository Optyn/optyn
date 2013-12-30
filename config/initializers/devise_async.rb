# Devise::Async.backend = :resque
Devise::Async.setup do |config|
  config.backend = :sidekiq
  config.queue   = :general_queue
end