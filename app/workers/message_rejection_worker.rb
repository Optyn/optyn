class MessageRejectionWorker
  @queue = :general_queue

  def self.perform(notifier_id)
    notification = MessageChangeNotifier.find(notifier_id)
    MessageMailer.send_rejection_notification(notification).deliver
  end
end