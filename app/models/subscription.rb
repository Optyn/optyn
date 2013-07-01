class Subscription < ActiveRecord::Base

  attr_accessible :email, :plan_id, :stripe_customer_token, :shop_id, :active
  attr_accessor :stripe_error

  belongs_to :plan
  belongs_to :shop

  validates :email, presence: true, unless: :new_record?
  validates :plan_id, presence: true
  validates :stripe_customer_token, presence: true, unless: :new_record?
  validates :shop_id, presence: true

  def self.create_stripe_customer(params)
    Stripe::Customer.create(email: params['subscription']['email'], card: params['stripeToken'],:plan=>params['stripe_plan_id'])
  end

  def update_plan(plan)
    self.update_attribute(:plan_id, plan.id)
    cu = Stripe::Customer.retrieve(self.stripe_customer_token) 
    cu.update_subscription(:plan => plan.plan_id)
  end
end
