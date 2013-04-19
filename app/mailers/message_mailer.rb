class MessageMailer < ActionMailer::Base
  default from: '"Gaurav Gaglani" <ggaglani@idyllic-software.com>'
  helper "merchants/messages"

  def send_announcement(message, message_user)
    @message = message
    @message_user = message_user

    mail(:to => %Q(#{@message_user.name} <#{@message_user.email}>), :subject => @message.personalized_subject(@message_user))
  end
end