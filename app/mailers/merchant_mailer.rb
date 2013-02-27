class MerchantMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def payment_notification(manager)
    @manager = manager
    mail(:to => @manager.email, :subject => "Payment Successful!")
  end
end
