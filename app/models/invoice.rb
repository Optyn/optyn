class Invoice < ActiveRecord::Base

	belongs_to :subscription
  
	attr_accessible :subscription_id, :stripe_customer_token, :stripe_invoice_id, :paid_status
	attr_accessible :amount
	attr_accessible :stripe_coupon_token, :stripe_coupon_percent_off ,:stripe_coupon_amount_off
	attr_accessible :stripe_plan_token
	attr_accessible :subtotal,:total
	attr_accessible :created_at

	after_create :make_shop_audit_entry

  def get_stripe_invoice
  	Stripe::Invoice.retrieve(self.stripe_invoice_id)
  end

  def make_shop_audit_entry
  	self.subscription.shop.create_audit_entry("Stripe Invoice closed. Stripe invoice id: #{self.stripe_invoice_id}. Paid Status: #{self.paid_status}")
  end
end


