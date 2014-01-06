class Charge < ActiveRecord::Base

  ## anyvaraible that directly comes from stripe as in hash 
  ## has stripe namespacing and token appended to it
  ## ex stripe_invoice_token
  attr_accessible :created, :livemode, :fee_amount, :stripe_charge_id
  attr_accessible :stripe_invoice_id, :description, :dispute
  attr_accessible :refunded, :paid, :amount, :card_last4
  attr_accessible :card_last4, :amount_refunded, :stripe_customer_token
  attr_accessible :fee_description, :stripe_invoice_token, :stripe_plan_token
  attr_accessible :stripe_charge_id

  scope :by_customer_tokens, ->(customer_token) { where(stripe_customer_token: customer_token) }

  scope :latest, order("charges.created DESC")

  def self.for_customer(customer_token)
    by_customer_tokens(customer_token).latest
  end

  def amount_in_dollars
    amount.to_f / 100
  end
end
