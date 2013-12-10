class MessageChangeWorker
  @queue = :general_queue

  def self.perform(notifier_id)
    notification = MessageChangeNotifier.find(notifier_id)
    id = MessageMailer.send_change_notification(notification).deliver
    MessageChangeNotifier.delete_previous_occourences(notification)
  end
end