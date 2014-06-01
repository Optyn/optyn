class EmailTrackingsController < ApplicationController
  def index
    begin
      EmailTracking.track(params[:uit])
    rescue
       Rails.logger.info "ERROR ==> #{e.message}"
       Rails.logger.info "ERROR ==> #{e.backtrace}"
    ensure
      redirect_to (params[:redirect_url] || SiteConfig.email_app_base_url)
    end
  end
end