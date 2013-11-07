class Charge < ActiveRecord::Base
  attr_accessible :created, :livemode, :fee_amount, :stripe_charge_id
  attr_accessible :stripe_invoice_id, :description, :dispute
  attr_accessible :refunded, :paid, :amount, :card_last4
  attr_accessible :card_last4, :amount_refunded, :stripe_customer_token
  attr_accessible :fee_description, :invoice_id
end
