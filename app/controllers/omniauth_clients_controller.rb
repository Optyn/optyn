class OmniauthClientsController < ApplicationController
	after_filter :nullify_omniauth_user_type

	def create
		# raise env['omniauth.auth'].to_yaml
		omniauth = env['omniauth.auth']
		session[:omniauth_user].present? ? create_user(omniauth) : create_manager(omniauth)
	end

	def failure
		if session[:manager]
			redirect_to new_merchants_manager_session_path, :flash => { :error => "Operation Cancelled" }
		else
			redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
		end
	end

	private

	def create_manager(omniauth)
		manager= Manager.from_omniauth(omniauth)
		if manager.new_record?
			@shop=Shop.new
			@shop.managers.build(:name => manager.name, :email => manager.email)
			@omniauth=omniauth
			render :template => "merchants/managers/registrations/new"
		else
			flash.notice = "Signed in!"
			sign_in_and_redirect manager
		end

	end

	def create_user(omniauth)
		user =User.from_omniauth(omniauth)
		if user.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect user
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_path
		end
	end

	def nullify_omniauth_user_type
		session[:omniauth_user] = nil
		session[:omniauth_manager] = nil
	end

	def after_sign_in_path_for(resource)
		return merchants_connections_path if current_merchants_manager
		super
	end
end