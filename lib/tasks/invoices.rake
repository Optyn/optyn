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
          :amount => stripe_invoice['amount_due'],
          :subtotal => stripe_invoice['subtotal'],
          :total => stripe_invoice['total'],
          :stripe_coupon_token => (stripe_token['discount']['coupon']['id'] rescue nil),
          :stripe_coupon_percent_off => (stripe_token['discount']['coupon']['percent_off'] rescue nil),
          :stripe_coupon_percent_off => (stripe_token['discount']['coupon']['amount_off'] rescue nil)
        }         
        invoice.save
      end # end of the subscription condition
    end #end of the invoices loop
  end #end of the task

  desc "Populate missing description for existing invoices"
  task :populate_description_to_invoices => :environment do
    require "stripe"
    Stripe.api_key = SiteConfig.stripe_api_key
    invoices = Invoice.all

    invoices.each do |invoice|
      begin
        stripe_invoice = Stripe::Invoice.retrieve(invoice.stripe_invoice_id)
      rescue Stripe::InvalidRequestError #handle 404 No such invoice
        puts "No such invoice found"
        stripe_invoice = nil
      end

      if !stripe_invoice.nil?
        description = stripe_invoice[:lines][:data].first["description"] rescue nil
        invoice.update_attributes(
                                          :description => description
                                        )
        puts "Found invoice and updated description to #{invoice.description}"
      end
    end #end of the invoices loop
  end #end of the task

end #end of the namespace