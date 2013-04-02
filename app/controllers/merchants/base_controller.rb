class Merchants::BaseController < ApplicationController

  layout 'merchants'

	before_filter :authenticate_merchants_manager!, :set_time_zone
	before_filter :active_subscription?

	helper_method :current_shop, :manager_signed_in?, :current_manager, :current_survey

	private
  def set_time_zone
    if current_shop.time_zone.present?
      Time.zone = current_shop.time_zone
    end
  end

	def active_subscription?
    unless current_manager.shop.is_subscription_active?
    	flash[:alert] = "Please update your payment details"
    	session[:return_to] = request.path
    	redirect_to merchants_upgrade_path
    end
  end

	def current_shop 
		@_shop ||= current_merchants_manager.shop if merchants_manager_signed_in?
	end

	def current_survey
		@_survey = (current_shop.survey || current_shop.send(:create_dummy_survey))
	end
end
