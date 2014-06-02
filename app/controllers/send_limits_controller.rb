class SendLimitsController < ApplicationController
  http_basic_authenticate_with name: "gaurav@optyn.com", password: "9p5yn123"

  def offset
    EmailCounter.initialize_if
    head :ok
  end

  def new
    @counter = REDIS[EmailCounter::SENDGRID_SEND_LIMIT]
  end

  def set
    EmailCounter.set_send_limit(params[:val]) if params[:val].present?
    head :ok
  end
end
