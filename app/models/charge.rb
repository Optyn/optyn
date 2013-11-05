class Charge < ActiveRecord::Base
  attr_accessible :created, :live_mode, :fee_amount
  attr_accessible :invoice, :description, :dispute
  attr_accessible :refunded, :paid, :amount
  attr_accessible :card_last4, :amount_refunded, :customer
  attr_accessible :fee_description
end
