class MerchantMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>"

  def payment_notification(manager, amount, connection_count, card_ending)
    @manager = manager
    @amount = amount
    @conn_count = connection_count
    @last4 = card_ending
    mail(:to => @manager.email, :subject => "Payment Successfull!")
  end

  def import_stats(file_import, counters)
    puts "*" * 100
    puts counters.inspect
    puts "-" * 100

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

  def notify_passing_free_tier(manager)
    @manager = manager
    mail(:to => @manager.email, :subject => "Congratulations!! You have exceeded the FREE tier limit.")
  end

  def notify_plan_upgrade(manager)
    @manager = manager
    @connections = manager.shop.active_connections.count
    mail(:to => @manager.email, :subject => "Congratulations!! You are growing.")
  end
end
