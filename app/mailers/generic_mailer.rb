class GenericMailer < ActionMailer::Base
  default from: "services@optyn.com",
          reply_to: "services@optyn.com"

  def announce_nightly_job_failure(content, method_name)
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>", "Alen Malkoc <alen@optyn.com>"],
         subject: "Failed running the nightly job of #{method_name}",
         body: content)
  end

  def announce_ping_failure(content)
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>", "Alen Malkoc <alen@optyn.com>"],
         subject: "Optyn response issue (#{Socket.gethostname})",
         body: content)
  end

  def announce_partner_inquiry(inquiry_id)
    @inquiry = PartnerInquiry.find(inquiry_id)

    mail(to: ["Alen Malkoc <alen@optyn.com>"],
      subject: "A new partner inquiry has come in (Company: #{@inquiry.company_name}, Id: #{@inquiry.id})")
  end
  
  def announce_marketing_agency_inquiry(inquiry_id)
    @inquiry = MarketingAgencyInquiry.find(inquiry_id)

    mail(to: ["Alen Malkoc <alen@optyn.com>"],
      subject: "A new marketing agency inquiry has come in (Company: #{@inquiry.company_name}, Id: #{@inquiry.id})")
  end
end
