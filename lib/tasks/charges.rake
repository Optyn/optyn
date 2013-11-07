namespace :charges do
  task :populate_charges_so_far => :environment do
    require "stripe"
    Stripe.api_key = SiteConfig.stripe_api_key
    stripe_charges = Stripe::Charge.all

    stripe_charges.each do |stripe_charge|
      charge = Charge.find_or_initialize_by_stripe_charge_id(stripe_charge.id)
      puts "Searching Customer with token: #{stripe_charge.customer}"
      subscription = Subscription.find_by_stripe_customer_token(stripe_charge.customer)

      if subscription.present?
        puts "Found the customer"
        charge.attributes = {
          :stripe_charge_id => stripe_charge.id,
          :created => stripe_charge.created,
          :livemode => stripe_charge.livemode,
          :fee_amount => stripe_charge.fee,
          :fee_description => stripe_charge.fee_details.to_s,
          :stripe_invoice_id => stripe_charge.invoice,
          :description => stripe_charge.description,
          :dispute => stripe_charge.dispute,
          :refunded => stripe_charge.refunded,
          :paid => stripe_charge.paid,
          :amount => stripe_charge.amount,
          :amount_refunded => stripe_charge.amount_refunded,
          :card_last4 => stripe_charge.card.last4,
          :stripe_customer_token => stripe_charge.customer,
        }         

        charge.invoice_id = Invoice.find_by_stripe_invoice_id(stripe_charge.invoice).id rescue nil

        charge.save
      end # end of the subscription condition
    end #end of the charges loop
  end #end of the task
end #end of the namespace