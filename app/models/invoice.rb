class Invoice < ActiveRecord::Base

	belongs_to :subscription
  
  attr_accessible :subscription_id, :stripe_customer_token, :stripe_invoice_id, :paid_status, :amount

  after_create :make_shop_audit_entry

  def get_stripe_invoice
  	Stripe::Invoice.retrieve(self.stripe_invoice_id)
  end

  def make_shop_audit_entry
  	self.subscription.shop.create_audit_entry("Stripe Invoice closed. Stripe invoice id: #{self.stripe_invoice_id}. Paid Status: #{self.paid_status}")
  end
end


