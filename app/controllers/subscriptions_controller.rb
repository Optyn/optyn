class SubscriptionsController < ApplicationController
  
  before_filter :require_manager
  before_filter :require_shop_local_and_inactive
  
  def upgrade
    @plan=Plan.find_by_plan_id("starter")
    @subscription=@plan.subscriptions.build
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
