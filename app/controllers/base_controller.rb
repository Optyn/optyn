class BaseController < ApplicationController
	def current_shop 
		current_merchants_manager.shop if merchants_manager_signed_in?
	end
end
