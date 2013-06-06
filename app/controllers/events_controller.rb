class EventsController < ApplicationController
  protect_from_forgery :except => [ :stripe_events ]
  
  require 'stripe_event_handlers'

  def stripe_events
    
    case params['type']

    when 'customer.subscription.updated'
      StripeEventHandlers.handle_customer_subscription_updated(params)
    when 'customer.subscription.created'
      StripeEventHandlers.handle_customer_subscription_created(params)
    when 'customer.subscription.deleted'
      StripeEventHandlers.handle_customer_subscription_deleted(params)
    when 'plan.created'
      StripeEventHandlers.handle_plan_created(params)
    when 'plan.updated'
      StripeEventHandlers.handle_plan_updated(params)
    when 'plan.deleted'
      StripeEventHandlers.handle_plan_deleted(params)
    else

    end

    respond_to do |format|
      format.html { head :ok}
    end

  end
end