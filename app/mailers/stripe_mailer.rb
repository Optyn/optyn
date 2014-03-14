class StripeMailer < ActionMailer::Base
  include SendGrid

  sendgrid_enable :opentrack

  default from: "services@optyn.com",
          reply_to: "services@optyn.com"

  def plan_change_notification(plan)
    @plan = plan
    mail(to: ["Gaurav Gaglani <gaurav@optyn.com>"],
         subject: "Plan created or changed"
    )
  end
end
