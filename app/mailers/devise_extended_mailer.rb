class DeviseExtendedMailer < Devise::Mailer
  helper :application

  default from: 'Optyn.com <services@optyn.com>',
          reply_to: "services@optyn.com"

  def welcome_user(user, password=nil)
    @user = user
    @password = password
    mail(to: %Q(#{@user.name} <#{@user.email}>), subject: "Welcome to Optyn!")
  end

  def welcome_manager(manager)
    @manager = manager
    mail(to: %Q(#{@manager.name} <#{@manager.email}>), subject: "Welcome to Optyn!")
  end
end
