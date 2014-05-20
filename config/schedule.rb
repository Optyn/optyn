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

every :day, :at => "2:15am" do
  rake "sitemap:refresh"	
end

# run to check whether shop email address is verified with SES server or not, then update shop
every :day, :at => "2:30am" do
  rake "shop:check_ses_verified"	
end

#run nightly jobs
every :day, :at => "3:00am" do
  runner "Util.nightly_jobs"
end

#run the task of populating shop credits every 3 days Eatsreet shops below.
every 3.days, :at => '3:15am' do
  rake "eatstreet:populate_shop_credits"
end

#run the messagecenter emails send every half hour but 10 PM - 4 AM
every '*/30 * * * *' do
  runner "Message.batch_send"
end