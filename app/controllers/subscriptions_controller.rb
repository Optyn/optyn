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
      @subscription.save
    rescue Exception => e
      self.stripe_error = e.to_s
      render 'upgrade'
    end

    flash[:notice]="Payment done successfully"
    redirect_to root_path
  end

end
