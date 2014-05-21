class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user
  belongs_to :message

  attr_accessible :message_user_id, :delivered, :message_smtp_id, :message_id

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
    if  message_user_id.present?
      if message.instance_of?(TemplateMessage)
        mail = MessageMailer.send_template(message, message_user)
      else
        mail = MessageMailer.send_announcement(message, message_user)
      end

      MessageMailHolder.create!(
        message_email_auditor_id: self.id,
        to: mail['to'].to_s,
        from: mail['from'].to_s,
        reply_to: mail['reply_to'].to_s,
        subject: mail['subject'].to_s,
        content_type: mail['content_type'].to_s,
        body: mail.body.to_s
      )

      message = self.message_user.message
      message.destroy if message.instance_of?(VirtualMessage)
    end
  end
end
