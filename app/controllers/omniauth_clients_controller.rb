class OmniauthClientsController < ApplicationController
	def create
		# raise env['omniauth.auth'].to_yaml
		omniauth = env['omniauth.auth']
		user =User.from_omniauth(omniauth) if session[:user].present?
		merchant= Merchant.from_omniauth(omniauth) if session[:merchant].present?
		if (user && user.persisted?) || (merchant || merchant.persisted?)
			flash.notice = "Signed in!"
			if session[:user].present?
				sign_in_and_redirect user
			else
				
				sign_in_and_redirect merchant
			end
		else
			session["devise.user_attributes"] = user.attributes if user
			session["devise.merchant_attributes"] = merchant.attributes if merchant
			redirect_to new_user_registration_path if user
			redirect_to new_merchant_registration_path if merchant

		end
	end

	def failure
		if session[:merchant]
			redirect_to new_merchant_session_path, :flash => { :error => "Operation Cancelled" }
		else
			redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
		end
	end
end