class EmailTrackingsController < ApplicationController
  def index
    return nil if !params[:token].present?
    data = Encryptor.decrypt_for_template(params[:token])
    EmailTracking.new.track(data, current_manager.id)
    redirect_url = TemplateUrl.select(:original_url).find(data[:template_url_id]).original_url
    redirect_to redirect_url
  end
end
