class Subscription < ActiveRecord::Base

  attr_accessible :email, :plan_id, :stripe_customer_token, :shop_id, :active
  attr_accessor :stripe_error

  belongs_to :plan
  belongs_to :shop

  def self.create_stripe_customer(params)
    Stripe::Customer.create(description: params['subscription']['email'], card: params['stripeToken'],:plan=>params['stripe_plan_id'])
  end
  
end
