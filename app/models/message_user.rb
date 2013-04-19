require 'messagecenter/process_manager'
require 'messagecenter/exceptions'

class MessageUser < ActiveRecord::Base
  belongs_to :message
  belongs_to :user
  belongs_to :receiver, class_name: "User", foreign_key: :user_id
  belongs_to :message_folder

  attr_accessible :message_id, :user_id, :message_folder_id, :is_read, :email_read, :is_forwarded, :received_at, :added_individually

  def self.create_message_receiver_entries(message_instance, receiver_ids, creation_errors, process_manager)
    error_message = ""
    deployment_counter = 0
    inbox_folder_id = MessageFolder.inbox_id
    message_instance_id = (message_instance.id rescue nil)
    receiver_ids.each do |receiver_identifier|


      begin
        message_receiver = find_or_generate!(receiver_identifier, message_instance_id)

        if message_receiver.message_folder_id.blank?
          message_receiver.update_attributes!(:message_id => message_instance_id,
                                              :message_folder_id => inbox_folder_id, :user_id => receiver_identifier,
                                              :received_at => Time.now)

          MessageEmailAuditor.create!(:message_user_id => message_receiver.id, :delivered => false)
        end
      rescue Messagecenter::Exceptions::MessageUserCreationException => invalid
        puts "Adding to creation errors:"
        puts invalid.message
        puts invalid.backtrace
        invalid.log
        creation_errors << invalid.message + "\n\n #{"-" * 100}"
      end

      deployment_counter += 1

      if deployment_counter >= 99
        deployment_counter = 0

        error_message = process_manager.relevant_existing_process_info
        unless error_message.blank?
          break
        end
      end

    end
    error_message
  end

  def email
    user.email
  end

  def name
    user.name
  end

  private
  def self.find_or_generate!(receiver_identifier, message_identifier)
    message_receiver = nil
    begin
      message_receiver = MessageUser.find_or_create_by_user_id_and_message_id(receiver_identifier, message_identifier)
    rescue ActiveRecord::RecordInvalid => invalid
      puts "-#-" * 33
      puts invalid.message
      puts invalid.backtrace
      puts "-*-" * 33

      raise(Messagecenter::Exceptions::MessageUserCreationException.new("Validation failed while persisting message id: #{message_id} and receiver id: #{receiver_id} \n\n #{e.message}"))
    end
    message_receiver
  end
end
