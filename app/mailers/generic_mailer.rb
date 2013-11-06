class GenericMailer < ActionMailer::Base
  default from: "services@optyn.com"

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
end
