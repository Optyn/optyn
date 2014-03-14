class DeviseExtendedMailer < Devise::Mailer
  include SendGrid

  sendgrid_enable :opentrack

  helper :application
  helper "merchants/messages"


  default from: 'Optyn.com <services@optyn.com>',
          reply_to: "services@optyn.com"

  def welcome_user(user, password=nil, shop_id=nil)
    sendgrid_category "Welcome Manager"

    @user = @resource = user
    @password = password
    @shop = Shop.find_by_id(shop_id)
    @skip_free_message = true
    mail(to: %Q(#{@user.full_name} <#{@user.email}>), subject: "Thank you for subscribing.")
  end

  def welcome_manager(manager)
    # sendgrid_category "Welcome Manager"

    @manager = @resource = manager
    mail(to: %Q(#{@manager.name} <#{@manager.email}>), subject: "Welcome to Optyn!")
  end
end
