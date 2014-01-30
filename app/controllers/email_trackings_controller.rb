class EmailTrackingsController < ApplicationController
  def index
    data = Encryptor.decrypt_for_template(params[:token])
    EmailTracking.new.track(data, current_manager.id)
    redirect_url = TemplateUrl.find(data[:template_url_id]).original_url
    redirect_to redirect_url
  end
end
