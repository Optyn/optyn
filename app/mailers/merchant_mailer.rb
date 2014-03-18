class MerchantMailer < ActionMailer::Base

  default from: "Optyn.com <services@optyn.com>",
          reply_to: "services@optyn.com"

 helper "merchants/file_imports"
 
  #shop_id, amount, connection_count, card_ending
  def payment_notification(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)
    @amount = ((options[:amount].to_f)/100)
    @conn_count = options[:connection_count]
    @last4 = options[:last4]
    mail(:to => receivers, :subject => "Payment Successful!")
  end

  #manager, amount, connection_count
  def invoice_payment_failure(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)
    @amount = ((options[:amount].to_f)/100)
    @conn_count = options[:connection_count]
    mail(:to => receivers, :subject => "Payment Failure!")
  end

  #manager, amount, connection_count
  def invoice_payment_succeeded(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)

    @amount = ((options[:amount].to_f)/100)
    @conn_count = options[:connection_count]
    mail(:to => receivers, :subject => "Payment Successful!")
  end

  def invoice_amount_credited(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)

    @amount = ((options[:amount].to_f)/100)
    @conn_count = options[:connection_count]
    mail(:to => receivers, :subject => "Amount Credited")
  end

  #manager
  def notify_passing_free_tier(options={})
    options = options.symbolize_keys
    @manager = Manager.find(options[:manager_id])
    mail(:to => @manager.email, :subject => "Congratulations!! You have exceeded the FREE tier limit.")
  end

  #manager
  def notify_plan_upgrade(options={})
    options = options.symbolize_keys
    @manager = Manager.find(options[:manager_id])
    @connections = options[:active_connections]
    mail(:to => @manager.email, :subject => "Congratulations!! You are growing.")
  end

  def import_stats(import_holder, output="", unparsed="")
    @file_import = import_holder
    @manager = @file_import.manager
    @counters = @file_import.stats.is_a?(Array) ? @file_import.stats.first : @file_import.stats

    unless output.blank?
      attachments['output.csv'] = output
    end

    unless unparsed.blank?
      attachments['unparsed.csv'] = unparsed
    end

    mail(to: "#{@manager.name} <#{@manager.email}>",
      bcc: ["gaurav@optyn.com", "alen@optyn.com"],
      subject: "Import user task is complete!")
  end

  def import_error(file_import, error)
    @file_import = file_import
    @manager = @file_import.manager
    @error = error
    mail(to: "#{@manager.name} <#{@manager.email}>",
      bcc: ["gaurav@optyn.com", "alen@optyn.com"],
      subject: "An Error occurred while importing users.")
  end

  private
  def fetch_payment_receivers(options)
    @shop = Shop.find(options[:shop_id])
    @manager = @shop.manager
    @subscription_email = @shop.subscription.email
    receivers = [@manager.email, @subscription_email].uniq
  end
end
