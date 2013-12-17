APPLICATION_ROOT = '/home/dev/code/helping-faceless'
RAILS_ENV = 'production'
DIR = File.join(APPLICATION_ROOT,'current')
SIDKIQ_PID = File.join(APPLICATION_ROOT,'shared/pids/sidekiq.pid')
PID_FILE = "/var/run/"
GOD_LOG = File.join(APPLICATION_ROOT,'shared/log/sidekiq.log')
God.pid_file_directory = PID_FILE
God.watch do |w|
  w.uid = 'dev'
  w.gid = 'dev'
  w.name = 'sidekiq'
  w.dir = DIR
  w.interval = 30.seconds
  w.start = "/bin/bash -c 'cd #{DIR} &&  /usr/bin/env bundle exec sidekiq -e #{RAILS_ENV} --logfile #{GOD_LOG} --pidfile #{SIDKIQ_PID} -d'"
  w.log = "#{APPLICATION_ROOT}/shared/log/god_sidekiq.log"
  w.start_grace = 30.seconds
  w.stop_signal = 'KILL'
  w.pid_file = SIDKIQ_PID
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
end
