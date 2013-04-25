class MerchantMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def payment_notification(manager)
    @manager = manager
    mail(:to => @manager.email, :subject => "Payment Successfull!")
  end

  def user_account_created_notifier(user, user_password)
  	@user = user
  	@user_password = user_password
  	mail(to: @user.email,  subject: "Optyn Account created")  	
  end
end
