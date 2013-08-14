class BetaUserMailer < ActionMailer::Base
	default from: '"Optyn.com" <email@optyn.com>'

	def send_invite(email_address)
		mail(:to => email_address, :subject => "Optyn is now live. Check it out!" )
	end	
end