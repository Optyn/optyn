require 'messagecenter/process_manager'
require 'messagecenter/exceptions'
require 'tracking_services/opens'

class MessageUser < ActiveRecord::Base
  include UuidFinder

  belongs_to :message
  belongs_to :user
  belongs_to :receiver, class_name: "User", foreign_key: :user_id
  belongs_to :message_folder
  has_one :message_email_auditor, dependent: :destroy

  before_create :assign_uuid

  attr_accessible :message_id, :user_id, :message_folder_id, :is_read, :email_read, :is_forwarded, :received_at, :added_individually

  delegate :email, :full_name, :first_name, to: :user

  scope :receivers_folder, ->(folder_id, user_id) { where(receivers_folder_conditions_hash(folder_id, user_id)) }

  scope :created_at_descending, :order => "message_users.created_at DESC"

  scope :include_message, includes(message: {manager: :shop})

  scope :include_user, includes(:user)

  scope :include_message_email_auditor, includes(:message_email_auditor)

  scope :for_message_ids, ->(message_ids) { where(message_id: message_ids) }

  scope :for_user_ids, ->(user_ids) { where(user_id: user_ids) }

  scope :joins_message, joins(:message)

  scope :any_read, where(["message_users.is_read = :is_read OR message_users.email_read = :email_read", {is_read: true, email_read: true}])

  scope :all_unread, where(["message_users.is_read <> :is_read AND message_users.email_read <> :email_read", {is_read: false, email_read: false}])

  scope :for_message_type_and_end_date, ->(klass) { joins_message
  .where(["messages.type LIKE :message_type", {message_type: klass.to_s}])
  .where(["messages.ending > :now", {now: Time.now}])
  }

  scope :for_message_owner, ->(owner_id) { joins_message
  .where(["messages.manager_id = :owner_id", {owner_id: owner_id}])
  }

  scope :opt_outs, where(opt_out: true)

  scope :coupon_relevance, select("DISTINCT(message_users.id) AS message_users_id, 
    CASE WHEN message_users.offer_relevant = true THEN SUM(1) END AS relevant_offer_count, 
    CASE WHEN message_users.offer_relevant = false THEN SUM(1) END AS irrelevant_offer_count")
                           .group("message_users.id")
                           .limit(1)

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
    TrackingServices::Opens.track(token)
  end

  def self.create_message_receiver_entries(message_instance, receiver_ids, creation_errors, process_manager)
    error_message = ""
    deployment_counter = 0
    inbox_folder_id = MessageFolder.inbox_id
    message_instance_id = (message_instance.id rescue nil)
    receiver_ids.each do |receiver_identifier|


      begin
        create_individual_entry(inbox_folder_id, message_instance_id, receiver_identifier)

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

  def self.create_individual_entry(inbox_folder_id, message_instance_id, receiver_identifier)
    MessageUser.transaction do
      message_receiver = find_or_generate!(receiver_identifier, message_instance_id)
      if message_receiver.message_folder_id.blank?
        message_receiver.update_attributes!(:message_id => message_instance_id,
                                            :message_folder_id => inbox_folder_id, :user_id => receiver_identifier,
                                            :received_at => Time.now)
      end

      message_audit = MessageEmailAuditor.find_or_create_by_message_user_id(:message_user_id => message_receiver.id, :delivered => false)
      message_audit.message_id = message_instance_id
      message_audit.save
    end
  end

  def self.coupon_messages_count(user_id, force = false)
    cache_key = create_count_cache_key(user_id, CouponMessage.to_s)
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      receivers_folder(MessageFolder.inbox_id, user_id).for_message_type_and_end_date(CouponMessage).all_unread.count
    end
  end

  def self.new_messages_count(user_id, force = false)
    cache_key = "message-user-#{user_id}-new-message-count"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      receivers_folder(MessageFolder.inbox_id, user_id).all_unread.count
    end
  end

  def self.special_messages_count(user_id, force = false)
    cache_key = create_count_cache_key(user_id, SpecialMessage.to_s)
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      receivers_folder(MessageFolder.inbox_id, user_id).for_message_type_and_end_date(SpecialMessage).all_unread.count
    end
  end

  def self.latest_messages(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-latest-messages-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_user_ids(user_id).include_message.include_user.limit(limit_count).all
    end
  end

  def self.merchant_engagement_count(manager_id, force = false)
    cache_key = "dashboard-merchant-engagement-count-#{manager_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      MessageUser.for_message_owner(manager_id).any_read.count
    end
  end

  def self.coupon_relevance
    where(offer_relevant: true)
  end

  def self.coupon_irrelevance
    where(offer_relevant: false)
  end

  def shop
    message.manager.shop
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

  def self.create_count_cache_key(user_id, message_type)
    "message-user-#{user_id}-message-type-#{message_type}-count"
  end

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end
end
