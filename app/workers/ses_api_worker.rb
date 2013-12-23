class SesApiWorker
  include Sidekiq::Worker

  def perform(message_email_auditor_id)
    # puts "~"*100
    # puts  "#{message_email_auditor_id} --> #{Time.now().to_i}"
    message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
    # puts  "#{message_email_auditor_id} --> #{Time.now().to_i}"
    message_user = message_email_auditor.message_user
    message = message_user.message

    # puts "+"*100
    ses_message_time_start = Time.now().to_i
    # puts  "#{message_email_auditor_id} --> #{ses_message_time_start}"
    begin
      ses_message = MessageMailer.send_announcement(message, message_user).deliver
    rescue Exception => ex
      puts ex
      Rails.logger.info "~"*100
      Rails.logger.info ex
      Rails.logger.info "~"*100
      return 
    end

    # puts  "#{message_email_auditor_id} --> #{Time.now()}"
    ses_message_time_end = Time.now().to_i
    message_email_auditor.update_attributes(delivered: true, ses_message_id: ses_message['message_id'].to_s.split(/@/).first)
    # puts  "#{message_email_auditor_id} --> #{Time.now().to_i}"
    message = message_email_auditor.message_user.message
    message.destroy if message.instance_of?(VirtualMessage)
    # puts "#{message_email_auditor_id} --> #{Time.now().to_i}"
    # puts "#{message_email_auditor_id} Time for SES API hit"
    # puts ses_message_time_end - ses_message_time_start
    # puts "~"*100
  end

end