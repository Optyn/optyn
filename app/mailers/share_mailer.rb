class ShareMailer < ActionMailer::Base
  default from: "services@optyn.com",
          reply_to: "services@optyn.com"

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
