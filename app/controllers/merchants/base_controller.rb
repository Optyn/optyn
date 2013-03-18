class Merchants::BaseController < ApplicationController
	alias_method :manager_signed_in?, :merchants_manager_signed_in?
	alias_method :current_manager, :current_merchants_manager

	before_filter :authenticate_merchants_manager!

	helper_method :current_shop, :manager_signed_in?, :current_manager

	private
	def current_shop 
		@_shop ||= current_merchants_manager.shop if merchants_manager_signed_in?
	end
end