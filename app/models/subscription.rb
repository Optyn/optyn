class Subscription < ActiveRecord::Base

  attr_accessible :email, :plan_id, :stripe_customer_token, :shop_id, :active
  attr_accessor :stripe_error

  belongs_to :plan
  belongs_to :shop
  has_many :invoices

  validates :email, presence: true, unless: :new_record?
  validates :plan_id, presence: true
  validates :stripe_customer_token, presence: true, unless: :new_record?
  validates :shop_id, presence: true, uniqueness: true

  after_create :create_stripe_customer_with_email

  def self.create_stripe_customer_card(subscription, params)
    if subscription.stripe_customer_token
      stripe_customer = Stripe::Customer.retrieve(subscription.stripe_customer_token)
      stripe_customer.update_subscription(card: params['stripeToken'], plan: params['stripe_plan_id'])
    else
      Stripe::Customer.create(email: params['subscription']['email'], card: params['stripeToken'], :plan => params['stripe_plan_id'])
    end

    Stripe::Customer.retrieve(subscription.stripe_customer_token)
  end

  def self.get_stripe_customer_card(subscription,params)
    if subscription.stripe_customer_token
      stripe_customer = Stripe::Customer.retrieve(subscription.stripe_customer_token)
    end
    stripe_customer
  end

  def update_plan(plan)
    self.update_attribute(:plan_id, plan.id)
    if self.stripe_customer_token.present?
      cu = Stripe::Customer.retrieve(self.stripe_customer_token)
      if cu['cards']['count'] > 0
        cu.update_subscription(:plan => plan.plan_id, :prorate => true)
      end
    end
  end

  private
  def create_stripe_customer_with_email
    SubscriptionBackgroundProcessor.perform_async(self.id)
  end
end
