class StripeMailer < ActionMailer::Base
  default from: "services@optynmail.com",
          reply_to: "services@optynmail.com"

  def plan_change_notification(plan)
    @plan = plan
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>"],
         subject: "Plan created or changed"
    )
  end
end
