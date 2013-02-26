Stripe.api_key=SiteConfig.stripe_api_key
STRIPE_PUBLIC_KEY=SiteConfig.stripe_public_key

StripeEvent.setup do
  
  subscribe 'charge.failed' do |event|
    # Define subscriber behavior based on the event object
    event.class #=> Stripe::Event
    event.type  #=> "charge.failed"
    event.data  #=> { ... }
  end

  subscribe 'customer.created', 'customer.updated' do |event|
    # Handle multiple event types
  end

  subscribe do |event|
    # Handle all event types - logging, etc.
  end

end