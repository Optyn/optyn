module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => true) if @subscription
  end

  def self.handle_customer_subscription_updated(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => true) if @subscription
  end

  def self.handle_customer_subscription_deleted(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => false) if @subscription
  end

  def self.handle_plan_deleted(params)
    @plan=Plan.find_by_plan_id(params['data']['object']['id'])
    @plan.destroy if @plan
  end
  
  def self.handle_plan_created(params)
    begin
      @plan = Stripe::Plan.retrieve(params['data']['object']['id'])
      Plan.create(:plan_id => @plan.id,
            :name => @plan.name,
            :interval => @plan.interval,
            :amount => @plan.amount,
            :currency=>@plan.currency) if @plan  

    rescue => e
  
    end
  end

  def self.handle_plan_updated(params)
    begin
      @stripe_plan = Stripe::Plan.retrieve(params['data']['object']['id'])
      @plan=Plan.find_by_plan_id(params['data']['object']['id']) if @stripe_plan
      @plan.update_attributes(:plan_id => @stripe_plan.id,
              :name => @stripe_plan.name,
              :interval => @stripe_plan.interval,
              :amount => @stripe_plan.amount,
              :currency=>@stripe_plan.currency) if @plan
    rescue => e
  
    end  
  end

end