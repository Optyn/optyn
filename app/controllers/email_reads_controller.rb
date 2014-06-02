class EmailReadsController < ApplicationController
   def open
    MessageUser.log_email_read(params[:token])
    send_file("#{Rails.public_path}/1px.png", :type => 'image/png', :disposition => 'inline')
  end
end
