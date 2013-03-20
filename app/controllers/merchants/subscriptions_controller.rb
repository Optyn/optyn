class Merchants::SubscriptionsController < Merchants::BaseController
  
  before_filter :require_manager
  before_filter :require_shop_local_and_inactive, :only => [:upgrade, :subscribe]
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]

  def upgrade
    @plan=Plan.find_by_plan_id("starter")
    @subscription=@plan.subscriptions.build
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
      @subscription=Subscription.new(params[:subscription])
      customer = Subscription.create_stripe_customer(params)
      @subscription.stripe_customer_token=customer.id

      if @subscription.save
        MerchantMailer.payment_notification(Manager.find_by_email(@subscription.email)).deliver
        flash[:notice]="Payment done successfully"
        redirect_to root_path
      else
        render 'upgrade'
      end

    rescue Exception => e
      @subscription.stripe_error = e.to_s
      render 'upgrade'
    end

  end
end
