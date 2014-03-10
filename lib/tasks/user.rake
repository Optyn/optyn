namespace :user do
  desc "update first_name and last_name for user"
  task :update_name => :environment do 
    puts "Rake task started at #{Time.now}"
    errors = []
    Rails.logger.info "Starting the User name change task"
    User.find_each(:batch_size => 1000) do |user|
      Rails.logger.info 
      begin
        if user.name.present? && user.first_name.blank? && user.last_name.blank?
       	  split_name = user.name.to_s.split(/\s/)
          first_name = split_name.first.to_s.capitalize
          last_name = split_name.shift.present? ? split_name.join(" ") : ""
       	  user.update_attributes(:first_name => first_name,:last_name => last_name)
        end
        Rails.logger.info "updated name for user : user_id: #{user.id}"
      rescue
        errors << user.id
      end
    end

    Rails.logger.error "User name change errors:"
    Rails.logger.error errors

    Rails.logger.info "Finished the User name change task"
  end
end
