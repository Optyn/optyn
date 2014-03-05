namespace :user do
  desc "update first_name and last_name for user"
  task :update_name => :environment do 
   puts "Rake task started at #{Time.now}"

   User.find_each(:batch_size => 1000) do |user|
   	split_name = user.name.to_s.split(/\s/)
    first_name = split_name.first.to_s.capitalize
    last_name = split_name.shift.present? ? split_name.join(" ") : ""
   	user.update_attributes(:first_name => first_name,:last_name => last_name)
   	puts "updated name for user : user_id: #{user.id}"
   end
  end
end
