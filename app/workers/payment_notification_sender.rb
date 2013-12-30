class PaymentNotificationSender
  include Sidekiq::Worker
  @queue = :payment_queue

  def perform(mailer, action, options)
    mailer.classify.constantize.send(action.to_sym, options).deliver
  end
end