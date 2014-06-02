#DEFINED ONLY FOR TEMPORARY TESTING. NEEDS TO BE DELETED LATER
class NotificationMailer < ActionMailer::Base
  default from: "services@optynmail.com",
          reply_to: "services@optynmail.com"

  def text_email
    mail(:to => [%{gaurav.checks@gmail.com}], :subject => "Retouching Base!", 
      # :body => "Hey Gaurav!\nThanks for reaching out to us.\nHere is the pricing that you wanted.\nThe chanrges of our ROR developers are 55 US dollars per hour.\n\n Thanks- Gaurav")
      :body => "Hey Gaurav!\nThanks for reaching out to us.\nThe charges of our ROR developers are 55 US dollars per hour.\n\n Thanks- Idyllic Software")
  end

  def text_email_jinesh
    mail(:to => ["jparekh@idyllic-software.com"], :subject => "Retouching Base!", 
      # :body => "Hey Gaurav!\nThanks for reaching out to us.\nHere is the pricing that you wanted.\nThe chanrges of our ROR developers are 55 US dollars per hour.\n\n Thanks- Gaurav")
      :body => "Hey Jinesh!\nIdyllic's Softwares Ruby on Rails development charges are 55 dollars correct? I will also need the hourly charges for Frontend developemnt.\nThanks a lot.")
  end

  def text_email_word_optyn
    mail(:to => ["rajaparekh@gmail.com"], :subject => "Retouching Base!", 
      :body => "Hey Jinesh/Gaurav!\nSo you have been using Optyn with Tiffinmantra.\n Would it possible to use it for Idyllic Software.\nThanks a lot.")
  end

  def brand_new
    mail(:to => [%{emira.hadziahmetovic@gmail.com}, %{alenzima@gmail.com}], :subject => "Welcome to your account")    
  end

  def general_information
    mail(:to => [%{gaurav.checks@gmail.com}], :subject => "Easy Steps to use Optyn")
  end
end