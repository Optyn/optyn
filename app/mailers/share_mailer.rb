class ShareMailer < ActionMailer::Base
  helper Merchants::MessagesHelper
  default from: "aishwarya@idyllic-software.com"

  def shared_email(users, message)
  	@message = message
    @shop = @message.shop
    mail(to: users, subject: 'Welcome to My Awesome Site')
  end
end
