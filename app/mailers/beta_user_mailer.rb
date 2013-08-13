class BetaUserMailer < ActionMailer::Base
	default from: '"Email" <email@optyn.com>'

	def send_invite(email_address)
		mail(:to => email_address, :subject => "Welcome to Optyn!", bcc: ['"Gaurav Gaglani" <gaurav@optyn.com>', '"Alen Malkoc" <alen@optyn.com>'])
	end	
end