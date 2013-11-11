class ShareMailer < ActionMailer::Base
  helper Merchants::MessagesHelper
  default from: "aishwarya@idyllic-software.com"

  def shared_email(user_email, message)
  	@message = message
    @shop = @message.shop
    @user_email = user_email
    mail(to: user_email, subject: "#{@message.name}")
  end
end
