class MessageRejectionWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true
  # @queue = :general_queue

  def perform(notifier_id)
    notification = MessageChangeNotifier.find(notifier_id)
    MessageMailer.send_rejection_notification(notification).deliver
  end
end