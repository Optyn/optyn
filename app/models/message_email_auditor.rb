class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user
  belongs_to :message

  attr_accessible :message_user_id, :delivered, :ses_message_id, :message_id

  after_create :enqueue_message

  scope :undelivered, where(delivered: false)

  scope :delivered, where(delivered: true)

  scope :bounced, where(bounced: true)

  scope :complaints, where(complaint: true)

  scope :bounced_or_complains, where("message_email_auditors.bounced = true OR message_email_auditors.complaint = true")

  BOUNCED = "arn:aws:sqs:us-east-1:946687270082:ses-bounces-queue"
  COMPLAINT = "arn:aws:sqs:us-east-1:946687270082:ses-complaints-queue"

  def self.check_for_failures()
    if Rails.env.production?
      Messagecenter::AwsDeliveryFailureChecker.failure_stats
    end
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
    if message_user_id.present?
      SesApiWorker.perform_async(self.id)
    end
  end
end
