class MessageMailHolder < ActiveRecord::Base
  belongs_to :message_email_auditor

  attr_accessible :message_email_auditor_id, :to, :from, :reply_to, :subject, :content_type, :body

  after_create :enqueue_message

  private
  def enqueue_message
    if EmailCounter::SENDGRID_KEY == EmailCounter.fetch_email_delivery_type
      Sidekiq::Client.push('queue' => 'sendgrid_queue', 'class' => 'SendgridWorker', 'args' => [self.id])
      EmailCounter.increment_sendgrid
    elsif EmailCounter::SES_KEY == EmailCounter.fetch_email_delivery_type
      Sidekiq::Client.push('queue' => 'ses_queue', 'class' => 'SesWorker', 'args' => [self.id])
      EmailCounter.increment_ses
    end
  end
end
