class BenchmarkSidekiq
  include Sidekiq::Worker
  include Sidekiq::Benchmark::Worker
  #INFO:this code is for benchmarking sidekiq only
  def perform(message_email_auditor_id)
    benchmark.first_metric do
      2.times do 
        message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
        message_user = message_email_auditor.message_user
        message = message_user.message

        begin
          ses_message = MessageMailer.send_announcement(message, message_user).deliver
        rescue Exception => ex
          puts ex
          Rails.logger.info "~"*100
          Rails.logger.info ex
          Rails.logger.info "~"*100
          return false
        end

        ses_message_time_end = Time.now().to_i
        message_email_auditor.update_attributes(delivered: true, message_smtp_id: ses_message['message_id'].to_s.split(/@/).first)
        message = message_email_auditor.message_user.message
        message.destroy if message.instance_of?(VirtualMessage)
      end
    end

    benchmark.second_metric do
      2.times do
        message_email_auditor = MessageEmailAuditor.find(message_email_auditor_id)
        message_user = message_email_auditor.message_user
        message = message_user.message

        begin
          ses_message = MessageMailer.send_announcement(message, message_user).deliver
        rescue Exception => ex
          puts ex
          Rails.logger.info "~"*100
          Rails.logger.info ex
          Rails.logger.info "~"*100
          return 
        end

        ses_message_time_end = Time.now().to_i
        message_email_auditor.update_attributes(delivered: true, message_smtp_id: ses_message['message_id'].to_s.split(/@/).first)
        message = message_email_auditor.message_user.message
        message.destroy if message.instance_of?(VirtualMessage)
      end
    end

    benchmark.finish
  end
end