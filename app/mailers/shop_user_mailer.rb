class ShopUserMailer < ActionMailer::Base
  default from: "Opty.com <services@optyn.com>",
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

  	mail(:to => @partner.email, :cc => fetch_copy_emails, :subject => "User Import complete")
  end

  def import_error(payload, error)
    @payload = payload
    @partner = @payload.partner
    @error = error
    mail(to: "#{@partner.name} <#{@partner.email}>", :cc => fetch_copy_emails, subject: "An Error occurred while importing users.")
  end

  private
    def fetch_copy_emails
      ["gaurav@optyn.com", "alen@optyn.com"]      
    end
end
