class Merchants::BaseController < ApplicationController
	alias_method :manager_signed_in?, :merchants_manager_signed_in?
	alias_method :current_manager, :current_merchants_manager

	before_filter :authenticate_merchants_manager!
	#before_filter :active_subscription?

	helper_method :current_shop, :manager_signed_in?, :current_manager, :current_survey

	private
	def active_subscription?
    unless current_manager.shop.is_subscription_active?
    	flash[:alert] = "Please update your payment details"
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
