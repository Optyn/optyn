namespace :connection do 
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
end