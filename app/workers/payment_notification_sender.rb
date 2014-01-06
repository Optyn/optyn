class PaymentNotificationSender
  include Sidekiq::Worker
  sidekiq_options :queue => :payment_queue, :backtrace => true
  # @queue = :payment_queue

  def perform(mailer, action, options)
    mailer.classify.constantize.send(action.to_sym, options).deliver
  end
end