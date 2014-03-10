namespace :user do
  desc "update first_name and last_name for user"
  task :update_name => :environment do
    puts "Rake task started at #{Time.now}"
    updates = []
    errors = []
    Rails.logger.info "Starting the User name change task"
    User.find_each(:batch_size => 10000) do |user|
      Rails.logger.info "Running for counts: #{user.id}"
       begin
        if user.name.present?
          split_name = user.name.to_s.split(/\s/).select(&:present?).collect(&:strip)
          if split_name.present?
            first_name = split_name.first.to_s.capitalize
            split_name.shift
            
            last_name = ""
            if split_name.size > 1
              if split_name.first.size == 1 || (split_name.first.size == 2 && split_name.first.include?("."))
                last_name = split_name.last
              else
                last_name = split_name.join(" ")
              end
            elsif split_name.size == 1
             last_name = split_name.first
            end

            #user.update_attributes(:first_name => first_name,:last_name => last_name)
            user.first_name = first_name
            user.last_name = last_name
            user.save(validate: false)
            Rails.logger.info "Found Last Name: #{last_name} | User: #{user.name} => #{user.first_name} | #{user.last_name}"
            updates << user.id
          end
        end
      rescue
        errors << user.id
      end
    end

    Rails.logger.error "User name change errors:"
    Rails.logger.error errors

    Rails.logger.info "Finished the User name change task"
  end
end