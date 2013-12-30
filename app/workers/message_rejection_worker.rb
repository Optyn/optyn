class MessageRejectionWorker
  include Sidekiq::Worker
  @queue = :general_queue

  def perform(notifier_id)
    notification = MessageChangeNotifier.find(notifier_id)
    MessageMailer.send_rejection_notification(notification).deliver
  end
end