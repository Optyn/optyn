class MerchantMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def payment_notification(manager)
    @manager = manager
    mail(:to => @manager.email, :subject => "Payment Successfull!")
  end

  def user_contacts_imported_notifier(manager,filepath,counter,valid_counters)
  	@manager = manager
    @counter = counter
    @valid_counters =  valid_counters
    attachments['invalid_records.csv'] = File.read(filepath)
  	mail(to: @manager.email,  subject: "Customer conctacts imported")  	
  end
end
