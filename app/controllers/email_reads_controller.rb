class EmailReadsController < ApplicationController
  def open
    MessageUser.log_email_read(params[:token])
    head :ok
  end
end
