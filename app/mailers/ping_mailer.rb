class PingMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def announce_failure(content)
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>", "Alen Malkoc <alen@optyn.com>"],
         subject: "Optyn response issue (#{Socket.gethostname})",
         body: content)
  end
end
