class PaymentNotificationSender
  @queue = :payment_queue

  def self.perform(mailer, action, options)
    mailer.classify.constantize.send(action.to_sym, options).deliver
  end
end