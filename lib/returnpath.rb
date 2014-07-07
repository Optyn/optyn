#Send emails to return path seed list
class Returnpath
  class << self
    def send_for_manager(manager_email, message_uuid)
      #########################################
      ## Copy the message you desire to send ##
      #########################################
      Rails.logger.info "Copying the message you desire to send"
      manager = Manager.find_by_email(manager_email)
      existing_message = Message.for_uuid(message_uuid)
      shop = manager.shop
      select_all = Label.select_all_instance(shop.id).first
      new_message = existing_message.copy_message #copy the given message.

      #assign the from and label and manager_id 
      new_message.manager_id = manager.id
      new_message.from = nil
      new_message.from = new_message.send(:canned_from)
      new_message.message_labels.destroy_all
      new_message.message_labels.build(label_id: select_all.id, shop_identifier: shop.id)
      new_message.save(validate: false)
      #############################################
      ## End Copy the message you desire to send ##
      #############################################

      #####################################################################
      ## Load the send list of returnpath for sending and create entries ##
      #####################################################################
      Rails.logger.info "Loading the seed file"
      file_location = "#{Rails.root}/db/seed_data/optyn_returnpath.csv"
      content = ""
      
      File.open(file_location, 'r') do |file|
        content = file.read 
      end

      wcontent = content.gsub(/\r/, "\n")
      csv_data = content.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
      csv_table = CSV.parse(csv_data, { headers: true})
      csv_table.each_with_index do |row, index|
        Rails.logger.info "Processing row: #{index + 1} Sending an email to: #{row[2]}"
        user = User.find_by_email(row[2])
        if user.present?
          connection = Connection.for_shop_and_user(shop.id, user.id)

          if connection.present?
            MessageUser.send(:create_individual_entry, MessageFolder.inbox_id, new_message.id, user.id)
            sleep(5)
          else
            Rails.logger.info "Could not find the connection"
          end
        else
          Rails.logger.info "Could not find the user with email: #{row[2]}"
        end
      end #end of parsing

      new_message.state = 'sent'
      new_message.save(validate: false)
      ############################################################################
      ## End of Load the send list of returnpath for sending and create entries ##
      ############################################################################
    end
  end #end of self block
end