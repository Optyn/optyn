# Resque
God.watch do |w|

  w.dir = RAILS_ROOT

  w.name = "resque-pool"
  w.interval = 30.seconds
  w.start = "cd #{RAILS_ROOT} && sudo -u www-data sh -c 'umask 002 && bundle exec resque-pool -d -E #{Rails.env}'"
  w.start_grace = 20.seconds
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/resque-pool.pid"

  w.behavior(:clean_pid_file)

  # restart if memory gets too high
  #w.transition(:up, :restart) do |on|
  #  on.condition(:memory_usage) do |c|
  #    c.above = 350.megabytes
  #    c.times = 2
  #  end
  #end

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
end