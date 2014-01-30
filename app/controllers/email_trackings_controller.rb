class EmailTrackingsController < ApplicationController
  def index
  	return nil if !params[:uit].present? # uit is user_info_token
    data = Encryptor.decrypt_for_template(params[:uit])
    data.merge!(:redirect_url => params[:redirect_url])
    EmailTracking.new.track(data)
    redirect_to params[:redirect_url]
  end
end
