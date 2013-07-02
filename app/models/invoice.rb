class Invoice < ActiveRecord::Base

	belongs_to :subscription
  
  attr_accessible :subscription_id, :stripe_customer_token, :stripe_invoice_id, :paid_status, :amount


  def get_stripe_invoice
  	Stripe::Invoice.retrieve(self.stripe_invoice_id)
  end
end
