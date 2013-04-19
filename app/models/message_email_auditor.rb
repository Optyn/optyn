class MessageEmailAuditor < ActiveRecord::Base
  belongs_to :message_user

  attr_accessible :message_user_id, :delivered

  after_create :enqueue_message

  private
  def enqueue_message
    Resque.enqueue(SesEmailSender, self.id)
  end
end
