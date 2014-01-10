class MessageChangeNotifier < ActiveRecord::Base
  belongs_to :message

  attr_accessible :message_id, :content, :rejection_comment, :subject, :send_on

  after_create :enqueue_for_notification, :assign_uuid

  scope :for_message_id, ->(message_identifier) { where(message_id: message_identifier) }

  scope :for_message_uuid, ->(message_uuid) { joins(:message).where(["messages.uuid = :message_uuid", {message_uuid: message_uuid}]) }

  scope :for_message_change_uuid, ->(message_change_uuid) { where(uuid: message_change_uuid) }

  scope :id_not_in, ->(identifier) { where(["message_change_notifiers.id NOT IN (:identifier)", {identifier: identifier}]) }

  def self.delete_previous_occourences(notification)
    for_message_id(notification.message_id).id_not_in(notification.id).destroy_all
  end

  def self.for_message_id_and_message_change_id(message_uuid, message_change_uuid)
    for_message_uuid(message_uuid).for_message_change_uuid(message_change_uuid).first
  end

  private
    def enqueue_for_notification
      MessageChangeWorker.perform_async(self.id)
    end

    def assign_uuid
      IdentifierAssigner.assign_random(self, 'uuid')
      self.save(validate: false)
    end
end
