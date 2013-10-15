class ShopUserMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>"

  def import_complete(payload, output, unparsed)
  	@payload = payload
  	@partner = payload.partner

  	unless output.blank?
  		attachments['output.csv'] = output	
  	end

  	unless unparsed.blank?
  		attachments['unparsed.csv'] = unparsed
  	end

  	mail(:to => @partner.email, :subject => "User Import complete")
  end

  def import_error(payload, error)
    @payload = payload
    @partner = @payload.partner
    @error = error
    mail(to: "#{@partner.name} <#{@partner.email}>", subject: "An Error occured while importing users.")
  end
end
