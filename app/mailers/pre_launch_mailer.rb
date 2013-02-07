class PreLaunchMailer < ActionMailer::Base
  default from: "Services <services@optyn.com>"

  def welcome(registration)
  	@registration = registration
  	mail(:to => registration.email)
  end
end
