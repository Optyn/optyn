class MessageMailer < ActionMailer::Base
  default from: '"Email" <email@optyn.com>',
          reply_to: "services@optyn.com"
          
  helper "merchants/messages"
  helper "message_mailer_forgery"
  helper "application"

  def send_announcement(message, message_user)
    @message = message
    @message_user = message_user
    @user = @message_user.user
    if @message.manager.present?
      @shop = @message.shop
      @shop_logo = true #flag set for displaying the shop logo or just the shop name
    end
    ShopTimezone.set_timezone(@shop)

    @partner = @shop.partner

    mail(to: %Q(#{'"' + @message_user.name + '"' + ' ' if @message_user.name}<#{@message_user.email}>), 
      bcc: "gaurav@optyn.com", 
      from: @message.from, 
      subject: @message.personalized_subject(@message_user),
      reply_to: @message.manager_email
      ) 
  end

  def error_notification(error_message)
    mail(to: ["gaurav@optyn.com", "alen@optyn.com"], subject: "Error while sending emails", body: error_message)
  end

  def shared_email(user_email, message)
    @message = message
    @shop = @message.shop
    ShopTimezone.set_timezone(@shop)
    @user_email = user_email
    mail(to: user_email, subject: "#{@message.name}")

    mail(to: user_email, 
      from: @message.from, 
      subject: @message.personalized_subject(user_email),
      reply_to: @message.manager_email
      ) 
  end

  def send_change_notification(message_change_notifier)
    @message_change_notifier = message_change_notifier
    @message_content = @message_change_notifier.content
    @actual_message = @message_change_notifier.message
    @owner_shop = @actual_message.shop

    ShopTimezone.set_timezone(@owner_shop)

    mail(from: "services@optyn.com",
      to: SiteConfig.eatstreet_curation_email,
      cc: ["gaurav@optyn.com", "alen@optyn.com", "ian@eatstreet.com"],
      subject: "Message Curation: #{@owner_shop.name}",
      reply_to: @actual_message.manager_email
    )
  end

  def send_rejection_notification(message_change_notifier)
    @message_change_notifier = message_change_notifier
    @message_content = @message_change_notifier.content
    @actual_message = @message_change_notifier.message
    @owner_shop = @actual_message.shop
    ShopTimezone.set_timezone(@shop)
    
    mail(
      from: SiteConfig.eatstreet_curation_email,
      to: @actual_message.manager_email,
      bcc: ["gaurav@optyn.com", "alen@optyn.com", "ian@eatstreet.com"],
      subject: "Message Rejected: #{@actual_message.name}",
      reply_to: "office@eatstreet.com"
    )
  end
end