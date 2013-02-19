class OmniauthClientsController < ApplicationController
	def create
		# raise env['omniauth.auth'].to_yaml
		omniauth = env['omniauth.auth']
		user = User.from_omniauth(omniauth)

		if user.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect user
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_path
		end
	end

	def failure
		redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
	end
end