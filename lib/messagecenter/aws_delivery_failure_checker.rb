require File.expand_path('../../../config/initializers/site_config', __FILE__)

module Messagecenter
  class AwsDeliveryFailureChecker
    def self.failure_stats
      sqs = AWS::SQS.new(
          :access_key_id => SiteConfig.aws_access_key_id,
          :secret_access_key => SiteConfig.aws_secret_access_key
      )

      queues = sqs.queues

      queues.each do |queue|
        queue_arn = queue.arn
        Rails.logger.info "*" * 100
        Rails.logger.info "Checking the Queue: #{queue_arn}"
        Rails.logger.info "-" * 100

        while queue.visible_messages > 0
          queue.receive_message(limit: 10) do |sns_message|
            sns_message_body = sns_message.body
            sns_message_detail = JSON.parse(sns_message_body)
            sns_message_str = sns_message_detail['Message']
            ses_message_detail = JSON.parse(sns_message_str)
            message_id = ses_message_detail["mail"]["messageId"]
            audit_entry = MessageEmailAuditor.find_by_ses_message_id(message_id)
            audit_entry.register_problem(queue_arn, sns_message_body) unless audit_entry.blank?
          end
        end
      end
    end
  end
end