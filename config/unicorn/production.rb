worker_processes 3
timeout 120
app_path = "/srv/apps/optyn"
rails_env = ENV['RAILS_ENV'] || 'production'
stderr_path "#{app_path}/shared/log/unicorn.stderr.log"
stdout_path "#{app_path}/shared/log/unicorn.stdout.log"
pid "#{app_path}/current/tmp/pids/unicorn.pid"
preload_app true
listen "/tmp/unicorn.optyn.sock", :backlog => 64

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
 old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis.quit
  #   Rails.logger.info('Disconnected from Redis')
  # end

  sleep 1
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis = ENV['REDIS_URI']
  #   Rails.logger.info('Connected to Redis')
  # end
end