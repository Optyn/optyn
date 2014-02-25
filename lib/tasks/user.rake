namespace :user do
  desc "update first_name and last_name for user"
  task :update_name => :environment do 
   puts "Rake task started at #{Time.now}"

   User.all.each do |user|
    first_name = user.name.to_s.split(/\s/).first.to_s.capitalize
    last_name = user.name.to_s.split(/\s/)[1..-1].join(" ")
   	user.update_attributes(:first_name => first_name,:last_name => last_name)
   end
  end
end
