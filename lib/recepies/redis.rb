Capistrano::Configuration.instance(true).load do
  namespace :redis do

    desc "Install redis"
    task :install do
      ["cd /tmp",
       "wget http://download.redis.io/redis-stable.tar.gz",
       "tar xvzf redis-stable.tar.gz", 
       "cd redis-stable", 
       "make", 
       "sudo cp /tmp/redis-stable/src/redis-benchmark /usr/local/bin/",
       "sudo cp /tmp/redis-stable/src/redis-cli /usr/local/bin/",
       "sudo cp /tmp/redis-stable/src/redis-server /usr/local/bin/",
       "sudo cp /tmp/redis-stable/redis.conf /etc/",
       "sudo sed -i 's/daemonize no/daemonize yes/' /etc/redis.conf",
       "sudo sed -i 's/^pidfile \/var\/run\/redis.pid/pidfile \/tmp\/redis.pid/' /etc/redis.conf"].each {|cmd| run cmd}
     end

     desc "Start the Redis server"
     task :start, :roles => :app do
      puts "*" * 100
      puts "Starting the redis server"
      puts "-" * 100
      run "redis-server /etc/redis.conf"
    end

    desc "Stop the Redis server"
    task :stop, :roles => :app do
      puts "*" * 100
      puts "Stopping the redis server"
      puts "-" * 100
      run 'echo "SHUTDOWN" | nc localhost 6379'
    end

  end
end
