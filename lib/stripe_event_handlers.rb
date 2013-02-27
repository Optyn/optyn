module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    begin
      @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
      @subscription.update_attributes(:active => true)
      MerchantMailer.payment_notification(Manager.find_by_email(@subscription.email))
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

  def self.handle_plan_deleted(params)
    @plan=Plan.find_by_plan_id(params['data']['object']['id'])
    @plan.destroy
  end
  
  def self.handle_plan_created(params)
    begin
      @plan = Stripe::Plan.retrieve(params['data']['object']['id'])
      Plan.create(:plan_id => @plan.id,
            :name => @plan.name,
            :interval => @plan.interval,
            :amount => @plan.amount,
            :currency=>@plan.currency)   

    rescue => e
  
    end
  end

  def self.handle_plan_updated(params)
    @stripe_plan = Stripe::Plan.retrieve(params['data']['object']['id'])
    @plan=Plan.find_by_plan_id(params['data']['object']['id'])
    @plan.update_attributes(:plan_id => @stripe_plan.id,
            :name => @stripe_plan.name,
            :interval => @stripe_plan.interval,
            :amount => @stripe_plan.amount,
            :currency=>@stripe_plan.currency) 
  end

end