class DeviseExtendedMailer < Devise::Mailer
  helper :application
  helper "merchants/messages"


  default from: 'Optyn.com <services@optyn.com>',
          reply_to: "services@optyn.com"

  def welcome_user(user, password=nil, shop_id=nil)
    @user = @resource = user
    @password = password
    @shop = Shop.find_by_id(shop_id)
    @from = %{"#{@shop.name.to_s.gsub(/["']/, "")}" <#{@shop.manager.email}>}
    @skip_free_message = true
    mail(from: @from, to: %Q(#{@user.full_name} <#{@user.email}>), subject: "Thank you for subscribing.")
  end

  def welcome_manager(manager)
    @manager = @resource = manager
    mail(to: %Q(#{@manager.name} <#{@manager.email}>), subject: "Welcome to Optyn!")
  end
end
