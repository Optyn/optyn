class MessageMailer < ActionMailer::Base
  default from: '"Email" <email@optyn.com>',
          reply_to: "services@optyn.com"
          
  helper "merchants/messages"
  helper "message_mailer_forgery"
  helper "application"

  def send_announcement(message, message_user)
    @message = message
    @message_user = message_user
    @user = @mesage_user.user
    if @message.manager.present?
      @shop = @message.shop
      @shop_logo = true #flag set for displaying the shop logo or just the shop name
    end

    mail(to: %Q(#{'"' + @message_user.name + '"' + ' ' if @message_user.name}<#{@message_user.email}>), 
      bcc: "gaurav@optyn.com", 
      from: @message.from, 
      subject: @message.personalized_subject(@message_user),
      reply_to: @message.manager_email
      ) 
  end

  def error_notification(error_message)
    mail(to: ["gaurav@optyn.com", "alen@optyn.com"], subject: "Error while sending the emal", body: error_message)
  end
end