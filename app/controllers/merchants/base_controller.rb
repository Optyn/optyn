class Merchants::BaseController < ApplicationController

	before_filter :authenticate_merchants_manager!, :set_time_zone, except: [:public_view]
	before_filter :check_connection_count, except: [:public_view]
	helper_method :current_shop, :manager_signed_in?, :current_manager, :current_survey

	private

  def is_current_manager_owner?
    unless current_manager.owner?
      redirect_to merchants_locations_path
      flash[:alert] ="Sorry,only Admin Manager can update location"
    end
  end

  def set_time_zone
    timezone = current_shop.time_zone.present? ? current_shop.time_zone : "Eastern Time (US & Canada)"
    Time.zone = timezone
  end

  def check_connection_count
    return if current_shop.active_connection_count <= Plan.starter.max
    flash[:alert] = "Please provide your payment details <a href='#{merchants_upgrade_subscription_path}'>here</a> in order to continue sending messages/emails." if current_shop.disabled?
  end

	
	def current_shop
		@_shop ||= current_merchants_manager.shop if merchants_manager_signed_in?
	end

	def current_survey
		@_survey = (current_shop.survey || current_shop.send(:create_dummy_survey))
	end
end
