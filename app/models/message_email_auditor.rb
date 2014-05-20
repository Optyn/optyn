class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user
  belongs_to :message

  attr_accessible :message_user_id, :delivered, :ses_message_id, :message_id

  after_create :enqueue_message

  scope :includes_user , includes(:message_user  => :user)

  scope :undelivered, where(delivered: false)

  scope :delivered, where(delivered: true)

  scope :bounced, where(bounced: true)

  scope :complaints, where(complaint: true)

  scope :bounced_or_complains, where("message_email_auditors.bounced = true OR message_email_auditors.complaint = true")

  def message
    message_user.message
  end

  def shop
    message.shop
  end

  def user
    message_user.user
  end

  private
  def enqueue_message
    #Conditon added as Optyn message receivers can email a received mesage in their inbox to a non Optyn user. 
    if message_user_id.present?
      SesApiWorker.perform_async(self.id)
    end
  end
end
