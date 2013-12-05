module Merchants::SubscriptionHelper
	#takes stripe_charge_id and returns plan object
	def get_plan_from_charge(charge)
		stripe_invoice_id = charge.stripe_invoice_token
		invoice = Invoice.where(:stripe_invoice_id=>stripe_invoice_id) rescue nil
		stripe_plan_token = invoice.stripe_plan_token rescue nil
		if !stripe_plan_token.nil?
			plan = Plan.where(:plan_id=>stripe_plan_token)
			return plan
		else
			return nil
		end
	end


end