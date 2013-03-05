class Merchants::AppsController < ApplicationController
	before_filter :authenticate_merchants_manager!
	before_filter :redirect_to_edit, :only => [:new, :create]
	before_filter :redirect_to_new, :except => [:new, :create]

	helper_method :current_shop

	def new
		@application = current_shop.oauth_application
	end

	def create
		current_shop.generate_oauth_token(params[:redirect_uri])
		redirect_to merchants_app_path
	end

	def show
		@application = current_shop.oauth_application
	end

	def edit 
		@application = current_shop.oauth_application
	end

	def update
		current_shop.generate_oauth_token(params[:redirect_uri], "true" == params[:reset])
		redirect_to merchants_app_path
	end

	private
	def current_shop
		@shop ||= current_merchants_manager.shop
	end

	def redirect_to_edit
		if current_shop.oauth_application.present?
			redirect_to edit_merchants_app_path
		end
	end

	def redirect_to_new
		unless current_shop.oauth_application.present?
			redirect_to new_merchants_app_path
		end
	end
end