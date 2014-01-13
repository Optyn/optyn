namespace :connections do 
  desc "Pick inactive connection and add the disconnect reason"
  task :assign_disconnect_event => :environment do
    inactive_connections = Connection.inactive
    inactive_connections.each_with_index do |connection, index|
      message_user = MessageUser.where(user_id: connection.user_id).first
      if message_user.present?
        auditor = message_user.message_email_auditor
        if auditor.bounced || auditor.complaint
          shop = connection.shop
          user = connection.user
          event = auditor.bounced ? "Bounced" : "Complaint"
          puts "#{index + 1} Making the connection between User: #{user.email} and Shop: #{shop.name} with event: #{event}"
          connection.disconnect_event = event
        else
          connection.disconnect_event = "Opt out"
        end
        connection.save
      end
    end
  end

  desc "Unsubscripe user from list."
  task :unsubscripe  => :environment do
    filepath = ENV["filepath"]
    manager = Manager.find_by_email(ENV["manager_email"])
    if !manager.blank?
      shop = manager.shop
      if filepath.present?
        csv_table = CSV.table(filepath, {headers: true})
        headers = csv_table.headers
        csv_table.each do |row|
          user = User.find_by_email(row[:unsubscribed])
          if !user.blank?
            connection = Connection.find_by_user_id_and_shop_id(user.id, shop.id)
            connection.make_inactive
            puts user.email
          else
            puts "invalid email address #{row[:unsubscribed]}"
          end
        end
      else
        puts "Invalid file #{ENV["filepath"]}."
      end
    else
      puts "Invalid manager email #{ENV["manager_email"]}."
    end
  end
end