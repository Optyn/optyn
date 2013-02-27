class SubscriptionsController < ApplicationController
  before_filter :require_manager
  
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
      @subscription.errors.add :base, "There was a problem with your credit card."
      render 'upgrade'
    end

    flash[:notice]="Payment done successfully"
    redirect_to root_path
  end

end
