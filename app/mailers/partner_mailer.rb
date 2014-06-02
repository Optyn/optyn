class PartnerMailer < ActionMailer::Base
  default from: "Optyn.com <services@optyn.com>",
          reply_to: "services@optyn.com"

  def import_complete(payload, output, unparsed)
  	@payload = payload
  	@partner = payload.partner

  	unless output.blank?
  		attachments['output.csv'] = output	
  	end

  	unless unparsed.blank?
  		attachments['unparsed.csv'] = unparsed
  	end

  	mail(:to => @partner.email, :cc => fetch_copy_emails, :subject => "Shop Import complete")
  end

  def import_error(payload, error)
    @payload = payload
    @partner = @payload.partner
    @error = error
    mail(to: "#{@partner.name} <#{@partner.email}>", :cc => fetch_copy_emails, subject: "An Error occured while importing shops.")
  end

  private
    def fetch_copy_emails
      ["gaurav@optyn.com", "alen@optyn.com"]      
    end
end
