module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => true)
  rescue => e
    Rails.logger.error e
  end

  def self.handle_customer_subscription_updated(params)
    @subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    status = params['data']['object']['customer']['subscription']['status']
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
      @stripe_plan = Stripe::Plan.retrieve(params['data']['object']['id'])

      @plan = Plan.find_by_plan_id(@stripe_plan.id) || Plan.new
      @plan.plan_id = @stripe_plan.id
      @plan.name = @stripe_plan.name
      @plan.interval = @stripe_plan.interval
      @plan.amount = @stripe_plan.amount
      @plan.currency = @stripe_plan.currency
      @plan.save!

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
                              :currency => @stripe_plan.currency)
    rescue => e
      Rails.logger.error e
    end
  end

  def self.handle_invoice_created(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    evaluated_plan = Plan.which(subscription.shop)
    subscription.update_plan(evaluated_plan) if evaluated_plan != subscription.plan
    ShopAudit.create(shop_id: subscription.shop.id, description: "Test Invoice Created")
  rescue => e
    Rails.logger.error e
  end

  def self.handle_invoice_payment_succeeded(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    Resque.enqueue(PaymentNotificationSender, "MerchantMailer", "invoice_payment_succeeded", {shop_id: subscription.shop.id, connection_count: conn_count, amount: amount})
  rescue => e
    Rails.logger.error e
  end

  def self.handle_invoice_payment_failed(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    subscription.update_attribute(:active, false)
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    Resque.enqueue(PaymentNotificationSender, 'MerchantMailer', 'invoice_payment_failure', {shop_id: subscription.shop.id, amount: amount, connection_count: conn_count})
  rescue => e
    Rails.logger.error e
  end

  def self.handle_invoice_updated(params)
    if params['data']['object']['closed']==true
      subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
      Invoice.create(
          :subscription_id => subscription,
          :stripe_customer_token => params['data']['object']['customer'],
          :stripe_invoice_id => params['data']['object']['id'],
          :paid_status => params['data']['object']['paid'],
          :amount => params['data']['object']['total']
      )
    end
  rescue => e
    Rails.logger.error e
  end

  def self.handle_coupon_created(params)
    coupon = Coupon.from_attrs(params)
    coupon.save!
  end

  def self.handle_coupon_deleted(params)
    coupon = Coupon.from_attrs(params)
    unless coupon.new_record?
      shop = Shop.find_by_coupon_id(coupon_id)
      shop.update_attribute(:coupon_id, nil)
      coupon.destroy
    end
  end

  def self.handle_customer_created(params)
    if params["discount"].present?
      discount_map = customer_params["discount"]
      manage_coupon(discount_map['coupon']['id'], params['id'])
    end
  end

  def self.handle_customer_updated(params)
    if params["discount"].present?
      discount_map = customer_params["discount"]
      manage_coupon(discount_map['coupon']['id'], params['id'])
    end
  end

  def self.handle_customer_discount_created(params)
    manage_coupon(params['coupon']['id'], params['customer'])
  end

  def self.handle_customer_discount_updated(params)
    manage_coupon(params['coupon']['id'], params['customer'])
  end

  def self.handle_customer_discount_deleted(params) 
    coupon, shop = fetch_coupon_and_shop(params['coupon']['id'], params['customer'])
    shop.coupon_id = nil
    shop.save(validate: false)
  end

  private
  def self.manage_coupon(coupon_stripe_id, customer_stripe_key)
    coupon, shop = fetch_coupon_and_shop(coupon_stripe_id, customer_stripe_key)
    shop.coupon_id = coupon.id
    shop.save(validate: false)
  end

  def self.fetch_coupon_and_shop(coupon_stripe_id, customer_stripe_key)
    coupon = (Coupon.find_by_stripe_id(coupon_stripe_id) rescue nil)
    subscription = Subscription.find_by_stripe_customer_token(customer_stripe_key)
    shop = subscription.shop
    [coupon, shop]
  end
end