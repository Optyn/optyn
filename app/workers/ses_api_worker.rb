class SesApiWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :message_queue, :backtrace => true
  # @queue = :message_queue

  def perform(message_email_auditor_id)
    message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
    message_user = message_email_auditor.message_user
    message = message_user.message

    ses_message_time_start = Time.now().to_i
    begin
      if message
        ses_message = MessageMailer.send_template(message, message_user).deliver
      else
        ses_message = MessageMailer.send_announcement(message, message_user).deliver
      end
    rescue Exception => ex
      puts ex
      Rails.logger.info "~"*100
      Rails.logger.info ex
      Rails.logger.info "~"*100
      raise ex #we need to raise the error so that airbrake gets it and job is retried
    end
    ses_message_time_end = Time.now().to_i
    message_email_auditor.update_attributes(delivered: true, ses_message_id: ses_message['message_id'].to_s.split(/@/).first)
    message = message_email_auditor.message_user.message
    message.destroy if message.instance_of?(VirtualMessage)
  end

end