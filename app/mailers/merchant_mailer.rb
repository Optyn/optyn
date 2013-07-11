class MerchantMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>"

  #shop_id, amount, connection_count, card_ending
  def payment_notification(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)
    @amount = options[:amount]
    @conn_count = options[:connection_count]
    @last4 = options[:last4]
    mail(:to => receivers, :subject => "Payment Successfull!")
  end

  #manager, amount, connection_count
  def invoice_payment_failure(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)
    @amount = options[:amount]
    @conn_count = options[:connection_count]
    mail(:to => receivers, :subject => "Payment Failure!")
  end

  #manager, amount, connection_count
  def invoice_payment_succeeded(options={})
    options = options.symbolize_keys
    receivers = fetch_payment_receivers(options)

    @amount = options[:amount]
    @conn_count = options[:connection_count]
    mail(:to => receivers, :subject => "Payment Successfull!")
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
    @connections = @manager.shop.active_connections.count
    mail(:to => @manager.email, :subject => "Congratulations!! You are growing.")
  end

  def import_stats(file_import, counters)
    @file_import = file_import
    @manager = @file_import.manager
    @counters = counters

    filepath = @file_import.create_unparsed_rows_file_if
    if filepath.present?
      attachments['invalid_records.csv'] = File.read(filepath)
    end

    mail(to: "#{@manager.name} <#{@manager.email}>", subject: "Import user task is complete!")
  end

  def import_error(file_import, error)
    @file_import = file_import
    @manager = @file_import.manager
    @error = error
    mail(to: "#{@manager.name} <#{@manager.email}>", subject: "An Error occured while importing users.")
  end

  private
  def fetch_payment_receivers(options)
    @shop = Shop.find(options[:shop_id])
    @manager = @shop.manager
    @subscription_email = @shop.subscription.email
    receivers = [@manager.email, @subscription_email].uniq
  end
end
