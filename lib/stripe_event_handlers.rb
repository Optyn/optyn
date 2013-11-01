module StripeEventHandlers

  def self.handle_customer_subscription_created(params)
    @subscription=Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    @subscription.update_attributes(:active => true)
  end

  def self.handle_customer_subscription_updated(params)
    @subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    status = params['data']['object']['status']
    if !@subscription.nil?
      @subscription.update_attributes(:active => ((status == 'active' || status == 'trialing') ? true : false))
    end
    # binding.pry
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
      @stripe_plan = Stripe::Plan.retrieve(params['data']['object']['id'])
      @plan = Plan.find_by_plan_id(@stripe_plan.id) || Plan.new
      @plan.plan_id = @stripe_plan.id
      @plan.name = @stripe_plan.name
      @plan.interval = @stripe_plan.interval
      @plan.amount = @stripe_plan.amount
      @plan.currency = @stripe_plan.currency
      @plan.save!
  end

  def self.handle_plan_updated(params)
      @stripe_plan = Stripe::Plan.retrieve(params['data']['object']['id'])
      @plan=Plan.find_by_plan_id(params['data']['object']['id']) if @stripe_plan
      @plan.update_attributes(:plan_id => @stripe_plan.id,
                              :name => @stripe_plan.name,
                              :interval => @stripe_plan.interval,
                              :amount => @stripe_plan.amount,
                              :currency => @stripe_plan.currency)
  end

  def self.handle_invoice_created(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    # binding.pry
    ##only start creating if subscription is not nil
    if !subscription.nil?
      evaluated_plan = Plan.which(subscription.shop)
      subscription.update_plan(evaluated_plan) if evaluated_plan != subscription.plan
      ShopAudit.create(shop_id: subscription.shop.id, description: "Test Invoice Created")
      create_invoice(subscription,params)
    end
  end

  def self.handle_invoice_payment_succeeded(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    Resque.enqueue(PaymentNotificationSender, "MerchantMailer", "invoice_payment_succeeded", {shop_id: subscription.shop.id, connection_count: conn_count, amount: amount})
    create_invoice(subscription,params)
  end

  def self.handle_invoice_payment_failed(params)
    subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
    subscription.update_attribute(:active, false)
    amount = params['data']['object']['total']
    conn_count = subscription.shop.active_connection_count
    Resque.enqueue(PaymentNotificationSender, 'MerchantMailer', 'invoice_payment_failure', {shop_id: subscription.shop.id, amount: amount, connection_count: conn_count})
    create_invoice(subscription,params)
  end

  def self.handle_invoice_updated(params)
    if params['data']['object']['closed']==true
      subscription = Subscription.find_by_stripe_customer_token(params['data']['object']['customer'])
      Invoice.create(
          :subscription_id => subscription.id,
          :stripe_customer_token => params['data']['object']['customer'],
          :stripe_invoice_id => params['data']['object']['id'],
          :paid_status => params['data']['object']['paid'],
          :amount => params['data']['object']['total']
      )
    end
  end

  def self.handle_coupon_created(params)
    stripe_coupon = params['data']['object']
    coupon = Coupon.from_attrs(stripe_coupon)
    coupon.save!
  end

  def self.handle_coupon_deleted(params)
    stripe_coupon = params['data']['object']
    coupon = Coupon.from_attrs(stripe_coupon)
    unless coupon.new_record?
      coupon.deleted = true
      coupon.save
    end
  end

  def self.handle_customer_created(params)
    discount_map = params['data']['object']["discount"]
    if discount_map.present?
      manage_coupon(discount_map['coupon']['id'], params, params['data']['object']['id'])
    end
  end

  def self.handle_customer_updated(params)
    discount_map = params['data']['object']["discount"]
    if discount_map.present?
      manage_coupon(discount_map['coupon']['id'], params['data']['object']['id'])
    end
  end

  def self.handle_customer_discount_created(params)
    manage_coupon(params['data']['object']['coupon']['id'], params['data']['object']['customer'])
  end

  def self.handle_customer_discount_updated(params)
    manage_coupon(params['data']['object']['coupon']['id'], params['data']['object']['customer'])
  end

  def self.handle_customer_discount_deleted(params) 
    coupon, shop = fetch_coupon_and_shop(params['data']['object']['coupon']['id'], params['data']['object']['customer'])
    shop.coupon_id = nil
    shop.save(validate: false)
  end

  def self.handle_charge_succeeded(params)
    Charge.create(
        :created => params[created],
      )
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

  def self.create_invoice(subscription,params)
      Invoice.create(
        :subscription_id => subscription.id,
        :stripe_customer_token => params['data']['object']['customer'],
        :stripe_invoice_id => params['data']['object']['id'],
        :paid_status => params['data']['object']['paid'],
        :amount => params['data']['object']['total']
      )
  end
end