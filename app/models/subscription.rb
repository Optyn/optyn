class Subscription < ActiveRecord::Base

  attr_accessible :email, :plan_id, :stripe_customer_token, :shop_id, :active
  attr_accessor :stripe_error

  belongs_to :plan
  belongs_to :shop
  has_many :invoices

  validates :email, presence: true, unless: :new_record?
  validates :plan_id, presence: true
  validates :stripe_customer_token, presence: true, unless: :new_record?
  validates :shop_id, presence: true

  after_create :create_stripe_customer_with_email

  def self.create_stripe_customer(params)
    Stripe::Customer.create(email: params['subscription']['email'], card: params['stripeToken'],:plan=>params['stripe_plan_id'])
  end

  def update_plan(plan)
    self.update_attribute(:plan_id, plan.id)
    if self.stripe_customer_token.present?
      cu = Stripe::Customer.retrieve(self.stripe_customer_token)
      cu.update_subscription(:plan => plan.plan_id, :prorate => false)
    end
  end

  private
  def create_stripe_customer_with_email
    Resque.enqueue(SubscriptionBackgroundProcessor, self.id)
  end
end
