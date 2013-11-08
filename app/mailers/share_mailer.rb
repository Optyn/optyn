class ShareMailer < ActionMailer::Base
  default from: "aishwarya@idyllic-software.com"

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: "aishwarya@idyllic-software.com", subject: 'Welcome to My Awesome Site')
  end
end
