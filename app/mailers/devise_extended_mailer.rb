class DeviseExtendedMailer < Devise::Mailer
  helper :application
  helper "merchants/messages"

  default from: 'Optyn.com <services@optyn.com>',
          reply_to: "services@optyn.com"

  def welcome_user(user, password=nil, shop_id=nil)
    @user = @resource = user
    @password = password
    @shop = Shop.find_by_id(shop_id)
    @skip_free_message = true
    mail(to: %Q(#{@user.name} <#{@user.email}>), subject: "Welcome to Optyn!")
  end

  def welcome_manager(manager)
    @manager = @resource = manager
    mail(to: %Q(#{@manager.name} <#{@manager.email}>), subject: "Welcome to Optyn!")
  end
end
