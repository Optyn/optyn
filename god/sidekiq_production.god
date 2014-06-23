#Welcome to "Process" heaven
#God rules here and it monitors all applcations irrespective of
#of their states -> zombie, alive or orphan
#In this "multithestic" universe of optyn , this god specifically looks
#after Reque background processes.

rails_env = "production"
raise "Please specify RAILS_ENV." unless rails_env

rails_release_root = "/srv/apps/optyn/releases/"
rails_root = "/srv/apps/optyn/current/"
rails_shared_root = "/srv/apps/optyn/shared"
rails_current_root = "/srv/apps/optyn/current"

#SET Maximum number of workers
#SET Maximum memory usage
memory_usage_max =  1500

puts "God is starting with:"
puts "RAILS_ENV = #{rails_env}"
puts "command to be execued cd #{rails_root}; bundle exec sidekiq start -C #{rails_current_root}/config/sidekiq.yml -d -L #{rails_current_root}/log/sidekiq.log"

God.watch do |w|
  w.dir      = "#{rails_current_root}"
  w.name     = "sidekiq"
  w.group    = 'sidekiq_group'
  w.interval = 30.seconds
  w.env      = 'production'
  w.start    = "bundle exec sidekiq start -C #{rails_current_root}/config/sidekiq.yml -d -L #{rails_current_root}/log/sidekiq.log"
  w.stop     = "bundle exec sidekiq stop -d -L #{rails_current_root}/log/sidekiq.log"
  w.log      = "#{rails_current_root}/log/sidekiq.log"
  w.start_grace = 60.seconds
  w.restart_grace = 60.seconds
  w.pid_file = "#{rails_current_root}/tmp/pids/sidekiq.pid"
  w.behavior(:clean_pid_file)

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = memory_usage_max.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
  w.lifecycle do |on|
    # Handle edge cases where deamon
    # can't start for some reason
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart] # If God tries to start or restart
      c.times = 5                     # five times
      c.within = 5.minutes            # within five minutes
      c.transition = :unmonitored     # we want to stop monitoring
      c.retry_in = 10.minutes         # for 10 minutes and monitor again
      c.retry_times = 5               # we'll loop over this five times
      c.retry_within = 2.hours        # and give up if flapping occured five times in two hours
    end
  end
end

