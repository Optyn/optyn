class SharedForwarder
  include Sidekiq::Worker
  @queue = :message_queue

  def perform(user_email, message_id, message_email_auditor_id)
  	message = Message.find(message_id)
    message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
    msg = MessageMailer.shared_email(user_email, message).deliver
    message_email_auditor.update_attributes(delivered: true, ses_message_id: msg['message_id'].to_s.split(/@/).first)
  end   
end