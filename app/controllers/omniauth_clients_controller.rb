class OmniauthClientsController < ApplicationController

	def create
		# raise env['omniauth.auth'].to_yaml
		omniauth = env['omniauth.auth']
		session[:user].present? ? create_user(omniauth) : create_manager(omniauth)
		
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

		if manager || manager.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect manager
		else
			session["devise.manager_attributes"] = manager.attributes
			redirect_to new_merchants_manager_registration_path
		end

	end

	def create_user(omniauth)
		user =User.from_omniauth(omniauth)

		if user && user.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect user
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_path
		end

	end

end