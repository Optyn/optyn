namespace :user do
  desc "Update the first_name and last_name where name is present and the former are blank"
  task :update_missing_first_and_last_name => :environment do
    puts "Rake task started at #{Time.now}"

    User.find_each(:batch_size => 10000) do |user|
      Rails.logger.info "Running for counts: #{user.id}"
       begin
        if user.name.present? && user.first_name.blank? && user.last_name.blank?
          name = user.name.downcase.gsub(/^mr\s/i, "").gsub(/^ms\s/i, "").gsub(/^dr\s/i, "")
          split_name = name.to_s.split(/\s/).select(&:present?).collect(&:strip)
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

            last_name = last_name.titleize

            user.first_name = first_name
            user.last_name = last_name
            user.save(validate: false)
            Rails.logger.info "User: #{user.name} => #{user.first_name} | #{user.last_name}"
          end
        end
      rescue
        errors << user.id
      end
    end

    Rails.logger.info "Finished the User name change task"
  end

  desc "Update first_name and last_name for user for the given shop_ids"
  task :update_name_for_shops => :environment do
    puts "Rake task started at #{Time.now}"
    updates = []
    errors = []
    Rails.logger.info "Starting the User name change task"
    shop_ids = ENV['shop_ids']

    shops = Shop.where(id: shop_ids.split(","))

    shops.each do |shop|
      shop.users.find_each(:batch_size => 10000) do |user|
        Rails.logger.info "Running for counts: #{user.id}"
         begin
          if user.name.present?
            name = user.name.downcase.gsub(/^mr\s/i, "").gsub(/^ms\s/i, "").gsub(/^dr\s/i, "")
            split_name = name.to_s.split(/\s/).select(&:present?).collect(&:strip)
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

              last_name = last_name.titleize

              user.first_name = first_name
              user.last_name = last_name
              user.save(validate: false)
              Rails.logger.info "Shop: #{shop.name} User: #{user.name} => #{user.first_name} | #{user.last_name}"
              updates << user.id
            end
          end
        rescue
          errors << user.id
        end
      end
    end

    Rails.logger.error "User name change errors:"
    Rails.logger.error errors

    Rails.logger.info "Finished the User name change task"
  end

  desc "Make the first_name and last_name fields blank where name is present."
  task :nullify_first_and_last_name => :environment do
    User.find_each(:batch_size => 10000) do |user|
      if user.name.present?
        user.first_name = nil
        user.last_name = nil

        user.save(validate: false)
      end

      Rails.logger.info("Running for user: #{user.id}")    
    end
  end

  desc "Make the user table's name column as just the first name, needs shop_ids"  
  task :shop_customer_name_as_first_name => :environment do
    shop_ids = ENV['shop_ids']

    shops = Shop.where(id: shop_ids.split(","))

    shops.each do |shop|
      shop.users.find_each(batch_size: 10000) do |user|
        if user.name.present?
          user.first_name = user.name
          user.save(validate: false)
          Rails.logger.info("Running for shop #{shop.name} user: #{user.id}")
        end
      end
    end
  end
end