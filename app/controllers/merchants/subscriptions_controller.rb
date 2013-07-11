class Merchants::SubscriptionsController < Merchants::BaseController

  before_filter :require_manager
  before_filter :require_shop_local_and_inactive, :only => [:upgrade, :subscribe]
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]

  def upgrade
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
    flash[:notice] = 'You will be charged based on the number of connections. For details, refer our pricing plans'
  end

  def edit_billing_info
    @plan= current_shop.subscription.plan
    @subscription = current_shop.subscription
  end

  def update_billing_info
    @subscription = current_shop.subscription

    begin
      @stripe_customer= Stripe::Customer.retrieve(@subscription.stripe_customer_token)
      @stripe_customer.card = params['stripeToken']
      @stripe_customer.save
      redirect_to root_path
    rescue => e
      @subscription.stripe_error = e.to_s
      render 'edit_billing_info'
    end
  end

  def subscribe
    begin
      @plan = current_shop.subscription.plan
      params[:subscription][:plan_id] = @plan.plan_id
      params[:stripe_plan_id] = @plan.id
      @subscription = current_shop.subscription || Subscription.new()
      @subscription.attributes = params[:subscription]

      @customer = @subscription.stripe_customer_token.present? ? Stripe::Customer.retrieve(@subscription.stripe_customer_token) : customer = Subscription.create_stripe_customer(params)
      if @subscription.stripe_customer_token.blank?
        @subscription.stripe_customer_token = customer.id
      end

      if @subscription.save
        @subscription.update_attribute(:active, true) if @subscription.stripe_customer_token.present?
        amount = @customer.subscription.plan.amount
        conn_count = current_shop.active_connection_count
        last4 = @customer.active_card.last4
        Resque.enqueue(PaymentNotificationSender, 'MerchantMailer', 'payment_notification', {shop_id: current_shop, amount: amount, conn_count: conn_count, last4: last4})
        flash[:notice]="Payment done successfully"
        redirect_to (session[:return_to] || root_path)
      else
        render 'upgrade'
      end

    rescue Exception => e
      if e.respond_to?(:code)
        @subscription.stripe_error = e.code.humanize
      else
        @subscription.stripe_error = e.to_s
      end
      render 'upgrade'
    end

  end
end
