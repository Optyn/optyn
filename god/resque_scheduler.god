rails_env   = ENV['RAILS_ENV']
raise "Please specify RAILS_ENV." unless rails_env
rails_root  = ENV['RAILS_ROOT'] || File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
num_workers = rails_env == 'production' ? 5 : 2

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque-scheduler"
  w.group    = 'resque'
  w.interval = 30.seconds
  w.env      = {"RAILS_ENV"=>rails_env, "BUNDLE_GEMFILE"=>"#{rails_root}/Gemfile"}
  w.start    = "bundle exec rake -f #{rails_root}/Rakefile resque:scheduler"
  w.log      = "#{rails_root}/log/resque-scheduler.log"

  # retart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
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
end