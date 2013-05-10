require 'messagecenter/process_manager'
require 'messagecenter/exceptions'

class MessageUser < ActiveRecord::Base
  belongs_to :message
  belongs_to :user
  belongs_to :receiver, class_name: "User", foreign_key: :user_id
  belongs_to :message_folder
  has_one :message_email_auditor, dependent: :destroy

  before_create :assign_uuid

  attr_accessible :message_id, :user_id, :message_folder_id, :is_read, :email_read, :is_forwarded, :received_at, :added_individually

  scope :receivers_folder, ->(folder_id, user_id) { where(receivers_folder_conditions_hash(folder_id, user_id)) }

  scope :created_at_descending, :order => "message_users.created_at DESC"

  scope :include_message, includes(message: {manager: :shop})

  scope :for_message_ids, ->(message_ids) { where(message_id: message_ids) }

  scope :for_user_ids, ->(user_ids) { where(user_id: user_ids) }

  def self.inbox_messages(user, page_number=1, per_page=Message::PER_PAGE)
    receivers_folder(MessageFolder.inbox_id, user.id).created_at_descending.include_message.page(page_number).per(per_page)
  end

  def self.saved_messages(user, page_number=1, per_page=Message::PER_PAGE)
    receivers_folder(MessageFolder.saved_id, user.id).created_at_descending.include_message.page(page_number).per(per_page)
  end

  def self.trash_messages(user, page_number=1, per_page=Message::PER_PAGE)
    receivers_folder(MessageFolder.deleted_id, user.id).created_at_descending.include_message.page(page_number).per(per_page)
  end

  def self.cached_user_inbox_count(user, force=false)
    cache_key = "inbox-count-user-#{user.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig[:ttls][:message_folder]) do
      inbox_count(user)
    end
  end

  def self.inbox_count(user)
    where(unread_conditions_hash.merge(receivers_folder_conditions_hash(MessageFolder.inbox_id, user.id))).count
  end

  def self.mark_inbox(messages, users)
    message_ids = messages.collect(&:id)
    user_ids = users.collect(&:id)

    update_all({message_folder_id: MessageFolder.inbox_id}, {message_id: message_ids, user_id: user_ids})
  end

  def self.mark_deleted(messages, users)
    message_ids = messages.collect(&:id)
    user_ids = users.collect(&:id)


    update_all({message_folder_id: MessageFolder.deleted_id}, {message_id: message_ids, user_id: user_ids})
  end

  def self.mark_saved(messages, users)
    message_ids = messages.collect(&:id)
    user_ids = users.collect(&:id)

    update_all({message_folder_id: MessageFolder.saved_id}, {message_id: message_ids, user_id: user_ids})
  end


  def self.mark_discarded(messages, users)
    message_ids = messages.collect(&:id)
    user_ids = users.collect(&:id)

    update_all({message_folder_id: MessageFolder.discarded_id}, {message_id: message_ids, user_id: user_ids})
  end

  def self.log_email_read(token)
    identifier = Base64.urlsafe_decode64(token)
    message_user_entry = MessageUser.find_by_uuid(identifier)
    if message_user_entry.present?
      message_user_entry.update_attribute(:email_read, true)
    end
  end

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
        end

        MessageEmailAuditor.find_or_create_by_message_user_id(:message_user_id => message_receiver.id, :delivered => false)

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

  def encode64_uuid
    Base64.urlsafe_encode64(self.uuid)
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

  def self.receivers_folder_conditions_hash(folder_id, user_id)
    {:message_folder_id => folder_id, :user_id => user_id}
  end

  def self.unread_conditions_hash
    {:is_read => false}
  end

  def assign_uuid
    self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/[-]/, "")
  end
end
