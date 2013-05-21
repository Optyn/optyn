class MerchantMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def payment_notification(manager)
    @manager = manager
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
end
