require 'resque/tasks'
require 'resque_scheduler/tasks'

Resque.logger = Logger.new("#{File.dirname(__FILE__)}/../../log/resque.log")

def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "./log/workers_error.log").to_s, "a"], 
                          :out => [(Rails.root + "./log/workers.log").to_s, "a"]}
  env_vars = {"BACKGROUND" => "1","QUEUE" => queue.to_s,"PIDFILE" => (Rails.root + "/tmp/resque.pid").to_s}
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "rake resque:work", ops)
    Process.detach(pid)
  }
end

# Start a scheduler, requires resque_scheduler >= 2.0.0.f
def run_scheduler
  puts "Starting resque scheduler"
  env_vars = {
    "BACKGROUND" => "1",
    "PIDFILE" => (Rails.root + "/tmp/resque_scheduler.pid").to_s,
    "VERBOSE" => "1"
  }
  ops = {:pgroup => true, :err => [(Rails.root + "./log/scheduler_error.log").to_s, "a"],
                          :out => [(Rails.root + "./log/scheduler.log").to_s, "a"]}
  pid = spawn(env_vars, "rake resque:scheduler", ops)
  Process.detach(pid)
end


namespace :resque do
  task :setup => :environment

  task "resque:setup" => :environment do
    ENV['QUEUE'] = '*'
  end

  task :setup => :environment do
      require 'resque'
      # require 'resque_scheduler'
      # require 'resque/scheduler'
 
      # you probably already have this somewhere
      #Resque.redis = 'localhost:6379'
      config = YAML.load_file(Rails.root.join('config', 'resque.yml'))
      Dir["#{Rails.root}/app/tasks/*.rb"].each { |file| require file } 
      Resque.redis = config[Rails.env]
      # Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_scheduler.yml'))
     
  end
end