class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user

  attr_accessible :message_user_id, :delivered, :ses_message_id

  after_create :enqueue_message

  scope :undelivered, where(delivered: false)

  BOUNCED = "ses-bounced-queue"
  COMPLAINT = "ses-complaints-queue"

  def register_problem(queue_arn, sns_message_body)
    self.body = sns_message_body

    if queue_arn.include?(BOUNCED)
      self.bounced = true
    elsif queue_arn.include?(COMPLAINT)
      self.complaint = true
    end

    self.save
  end

  private
  def enqueue_message
    Resque.enqueue(SesEmailSender, self.id)
  end
end
