class StripeMailer < ActionMailer::Base
  default from: "services@optyn.com"

  def plan_change_notification(plan)
    @plan = plan
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>", "Alen Malkoc <alen@optyn.com>"],
         subject: "Plan created or changed"
    )
  end
end
