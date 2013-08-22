class SesEmailSender
  @queue = :message_queue

  def self.perform(message_email_auditor_id)
    message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
    message_user = message_email_auditor.message_user
    message = message_user.message

    ses_message = MessageMailer.send_announcement(message, message_user).deliver
    message_email_auditor.udpate_attribute(:delivered, true)
    message_email_auditor.update_attributes(ses_message_id: ses_message['message_id'].to_s.split(/@/).first)
  end
end