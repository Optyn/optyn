module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    begin
      @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
      @subscription.update_attributes(:active => true)
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
    
  end

  def self.handle_customer_subscription_updated(params)

    begin
      @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
      @subscription.update_attributes(:active => true) 
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end

  end

  def self.handle_customer_subscription_deleted(params)

    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => false) if @subscription
    
  end

end