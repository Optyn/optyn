class PartnerMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>"

  def import_complete(payload)
  	@payload = payload
  	@partner = payload.partner
  	mail(:to => @partner.email, :subject => "Shop Import complete")
  end
end
