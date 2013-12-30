class SubscriptionBackgroundProcessor
  include Sidekiq::Worker
  @queue = :payment_queue

  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)
    unless subscription.stripe_customer_token.present?
      stripe_customer = Stripe::Customer.create(email: subscription.shop.manager.email)
      subscription.stripe_customer_token = stripe_customer['id']
      subscription.save!
    end
  end
end