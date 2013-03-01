class PreLaunchMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>"

  def welcome(registration)
  	@registration = registration
  	mail(:to => registration.email)
  end
end
