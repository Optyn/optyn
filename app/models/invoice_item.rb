class InvoiceItem < ActiveRecord::Base
  attr_accessible :amount, :description, :livemode, :proration, :stripe_customer_token, :stripe_invoice_item_token, :stripe_invoice_token
end
