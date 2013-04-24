class EmailReadLoggerController < ApplicationController
  def info
    MessageUser.log_email_read(params[:token])
    head :ok
  end
end
