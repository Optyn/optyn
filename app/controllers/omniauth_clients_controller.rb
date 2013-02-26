class OmniauthClientsController < ApplicationController
	def create
		# raise env['omniauth.auth'].to_yaml
		omniauth = env['omniauth.auth']
		user =User.from_omniauth(omniauth) if session[:user].present?
		manager= Manager.from_omniauth(omniauth) if session[:manager].present?
		if (user && user.persisted?) || (manager || manager.persisted?)
			flash.notice = "Signed in!"
			if session[:user].present?
				sign_in_and_redirect user
			else
				
				sign_in_and_redirect manager
			end
		else
			session["devise.user_attributes"] = user.attributes if user
			session["devise.manager_attributes"] = manager.attributes if manager
			redirect_to new_user_registration_path if user
			redirect_to new_merchants_manager_registration_path if manager

		end
	end

	def failure
		if session[:manager]
			redirect_to new_merchants_manager_session_path, :flash => { :error => "Operation Cancelled" }
		else
			redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
		end
	end
end