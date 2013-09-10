class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user

  attr_accessible :message_user_id, :delivered, :ses_message_id

  after_create :enqueue_message

  scope :undelivered, where(delivered: false)

  BOUNCED = "arn:aws:sqs:us-east-1:946687270082:ses-bounces-queue"
  COMPLAINT = "arn:aws:sqs:us-east-1:946687270082:ses-complaints-queue"

  def self.check_for_failures()
    Messagecenter::AwsDeliveryFailureChecker.failure_stats
  end

  def register_problem(queue_arn, sns_message_body)
    self.body = sns_message_body

    if queue_arn.include?(BOUNCED)
      self.bounced = true
    elsif queue_arn.include?(COMPLAINT)
      self.complaint = true
    end

    self.delivered = false

    self.save
  end

  private
  def enqueue_message
    Resque.enqueue(SesEmailSender, self.id)
  end
end
