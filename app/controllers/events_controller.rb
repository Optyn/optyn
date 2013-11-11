class EventsController < ApplicationController
  protect_from_forgery :except => [:stripe_events]

  require 'stripe_event_handlers'

  def stripe_events
    Rails.logger.info '='*100
    Rails.logger.info 'Webhook ' + params['type'] +' has been called'
    Rails.logger.info '='*100
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
      when 'invoice.created'
        StripeEventHandlers.handle_invoice_created(params)
      when 'invoice.payment_succeeded'
        StripeEventHandlers.handle_invoice_payment_succeeded(params)
      when 'invoice.payment_failed'
        StripeEventHandlers.handle_invoice_payment_failed(params)
      when 'invoice.updated'
        StripeEventHandlers.handle_invoice_updated(params)
      when 'coupon.created'
        StripeEventHandlers.handle_coupon_created(params)
      when 'coupon.deleted'
        StripeEventHandlers.handle_coupon_deleted(params)
      when 'customer.created'
        StripeEventHandlers.handle_customer_created(params)
      when 'customer.updated'
        StripeEventHandlers.handle_customer_updated(params)
      when 'customer.discount.created'
        StripeEventHandlers.handle_customer_discount_created(params)
      when 'customer.discount.updated'
        StripeEventHandlers.handle_customer_discount_updated(params)
      when 'customer.discount.deleted'
        StripeEventHandlers.handle_customer_discount_deleted(params)
      when 'charge.succeeded'
        StripeEventHandlers.handle_charge_succeeded(params)
      else

    end

    respond_to do |format|
      format.html { head :ok }
    end

  end
end