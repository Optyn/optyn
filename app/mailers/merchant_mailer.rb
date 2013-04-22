class MerchantMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def payment_notification(manager)
    @manager = manager
    mail(:to => @manager.email, :subject => "Payment Successfull!")
  end

  def connected_users_record(manager,filename)
  	@manager = manager
  	attachments["optyn_user_record.csv"] = File.read("#{Rails.root.to_s}/tmp/#{filename}.csv")
  	mail(:to => @manager.email, :subject => "New Optyn user record")
  end
end
