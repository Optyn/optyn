#Welcome to "Process" heaven
#God rules here and it monitors all applcations irrespective of
#of their states -> zombie, alive or orphan
#In this "multithestic" universe of optyn , this god specifically looks
#after Reque background processes.
#Now only if I can start a cult around this one; I will end up super rich :P

rails_env = ENV['RAILS_ENV'] || "staging"
raise "Please specify RAILS_ENV." unless rails_env

if rails_env == "staging"
  rails_root == ""
elsif rails_env == "production"
  rails_root == ""
else
  rails_root  = ENV['RAILS_ROOT'] || File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
end 
rails_release_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
#SET Maximum number of workers 
num_workers = rails_env == 'production' ? 5 : 1 
#SET Maximum memory usage 
memory_usage_max = rails_env == 'production' ? 350 : 350

puts "God is starting with:"
puts "RAILS_ENV = #{ENV['RAILS_ENV']}"
puts "and number of workers #{num_workers} + 1"
puts "command to be execued QUEUES=* bundle exec rake -f #{rails_root}/current/Rakefile environment resque:work"

0.upto(num_workers) do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}/current/"
    w.name     = "resque-#{num}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.env      = {"QUEUES"=>"*", "RAILS_ENV"=>rails_env,'PIDFILE' => "#{rails_root}/shared/pids/resque/#{w.name}.pid"}
    w.start    = "QUEUES=* bundle exec rake -f #{rails_root}/current/Rakefile environment resque:work"
    w.log      = "#{rails_root}/shared/log/resque-#{num}.log"

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = memory_usage_max.megabytes
        c.times = 2
      end
      # on.condition(:cpu_usage) do |c|
      #   # Restart deamon if cpu usage goes
      #   # above 90% at least five times
      #   c.above = 95.percent
      #   c.times = 5
      # end
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
end