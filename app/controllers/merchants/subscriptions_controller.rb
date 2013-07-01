class Merchants::SubscriptionsController < Merchants::BaseController
  
  before_filter :require_manager
  before_filter :require_shop_local_and_inactive, :only => [:upgrade, :subscribe]
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]
  def upgrade
    @plan=Plan.starter
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
    flash[:notice] = 'You will be charged based on the number of connections. For details, refer our pricing plans'
  end

  def edit_billing_info
    @plan=current_merchants_manager.shop.subscription.plan
    @subscription = current_merchants_manager.shop.subscription
  end

  def update_billing_info
    @subscription = current_merchants_manager.shop.subscription
    
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
      @plan=Plan.starter
      @subscription=Subscription.new(params[:subscription])
      customer = Subscription.create_stripe_customer(params)
      @subscription.stripe_customer_token=customer.id

      if @subscription.save
        @subscription.update_attribute(:active, true)
        amount = customer.subscription.plan.amount
        conn_count = current_shop.active_connection_count
        last4 = customer.active_card.last4
        MerchantMailer.payment_notification(Manager.find_by_email(@subscription.email), amount, conn_count, last4).deliver
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
