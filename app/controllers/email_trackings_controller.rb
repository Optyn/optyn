class EmailTrackingsController < ApplicationController
  def index
    return nil if !params[:token].present?
    data = Encryptor.decrypt_for_template(params[:token])
    EmailTracking.new.track(data)
    redirect_to data[:redirect_url]
  end
end
