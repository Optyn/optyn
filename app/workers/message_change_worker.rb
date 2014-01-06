class MessageChangeWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true
  # @queue = :general_queue

  def perform(notifier_id)
    notification = MessageChangeNotifier.find(notifier_id)
    MessageMailer.send_change_notification(notification).deliver
    MessageChangeNotifier.delete_previous_occourences(notification)
  end
end