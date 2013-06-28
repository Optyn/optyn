# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
#set :environment, "development"
set :output, "#{path}/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
rvm_trust_rvmrcs_flag=1
#update the latitude and longitudes for shops
every :day, :at => "1:30am" do
  rake "geo:fetch_location"
end

every :day, :at => "2:00am" do
  rake "pg:backup"
end

#run nightly jobs
every :day, :at => "3:00am" do
  runner "Util.nightly_jobs"
end

#run the messagecenter emails send every half hour but 10 PM - 4 AM
every '*/30 4-22 * * *' do
  runner "Message.batch_send"
end

#run a check for number of connections for each shop
every :day, :at => "1:00am" do
	runner "Shop.batch_check_subscriptions"
end
