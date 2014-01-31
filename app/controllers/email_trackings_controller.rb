class EmailTrackingsController < ApplicationController
  def index
    begin
      # uit is user_info_token
      data = Encryptor.decrypt_for_template(params[:uit]) if params[:uit].present?
      if data
        data.merge!(:redirect_url => params[:redirect_url])
        EmailTracking.new.track(data)
      end
    rescue Exception => e
      p "ERROR ==> #{e.message}"
      p "ERROR ==> #{e.backtrace}"
    ensure
      redirect_to (params[:redirect_url] || SiteConfig.app_base_url)
    end
  end
end
