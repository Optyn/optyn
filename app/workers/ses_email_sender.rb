class SesEmailSender
  @queue = :message_queue

  def self.perform(message_email_auditor_id)
    message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
    message_user = message_email_auditor.message_user
    message = message_user.message

    MessageMailer.send_announcement(message, message_user).deliver
    message_email_auditor.destroy
  end
end