namespace :invoices do
  task :populate_invoices_so_far => :environment do
    require "stripe"
    Stripe.api_key = SiteConfig.stripe_api_key
    stripe_invoices = Stripe::Invoice.all

    stripe_invoices.each do |stripe_invoice|
      invoice = Invoice.find_or_initialize_by_stripe_invoice_id(stripe_invoice['id'])
      puts "Searching Customer with token: #{stripe_invoice['customer']}"
      subscription = Subscription.find_by_stripe_customer_token(stripe_invoice['customer'])

      if subscription.present?
        puts "Found the customer"
        invoice.attributes = {
          :subscription_id => subscription.id,
          :stripe_customer_token => stripe_invoice['customer'],
          :stripe_invoice_id => stripe_invoice['id'],
          :paid_status => stripe_invoice['paid'],
          :amount => stripe_invoice['amount_due']
        }         
        invoice.save
      end # end of the subscription condition
    end #end of the invoices loop
  end #end of the task
end #end of the namespace