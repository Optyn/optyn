module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => true) if @subscription
  rescue => e
    Rails.logger.error e
  end

  def self.handle_customer_subscription_updated(params)
    @subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    status =  params['data']['object']['customer']['subscription']['status']
    @subscription.update_attributes(:active => ((status == 'active' || status == 'trialing') ? true : false))
  rescue => e
    Rails.logger.error e
  end

  def self.handle_customer_subscription_deleted(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => false) if @subscription
  rescue => e
    Rails.logger.error e
  end

  def self.handle_plan_deleted(params)
    @plan=Plan.find_by_plan_id(params['data']['object']['id'])
    @plan.destroy if @plan
  rescue => e
    Rails.logger.error e
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
      Rails.logger.error e
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
      Rails.logger.error e
    end  
  end

  def handle_invoice_created(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    evaluated_plan = Plan.which(subscription.shop)
    subscription.update_plan(evaluated_plan) if evaluated_plan != subscription.plan
  rescue => e
    Rails.logger.error e
  end

  def handle_invoice_payment_succeeded
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    MerchantMailer.invoice_payment_succeeded(Manager.find_by_email(subscription.email), amount, conn_count).deliver
  rescue => e
    Rails.logger.error e
  end

  def handle_invoice_payment_failed
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    MerchantMailer.invoice_payment_failure(Manager.find_by_email(subscription.email), amount, conn_count).deliver
  rescue => e
    Rails.logger.error e
  end
end