class OmniauthClientsController < ApplicationController
	after_filter :nullify_omniauth_user_type, except: [:login_type]

	def create
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

  def login_type
    if "shop" == params[:user_type]
      session[:omniauth_manager] = true
      session[:omniauth_user] = nil
    else
      session[:omniauth_manager] = nil
      session[:omniauth_user] = true
    end

    head :ok
  end

	private

	def create_manager(omniauth)
		manager, authentication = Manager.create_from_omniauth(omniauth)

		if manager.new_record?
			@shop = Shop.new
			@shop.managers.build(:name => manager.name, :email => manager.email)
			@omniauth = omniauth
			render :template => "merchants/managers/registrations/new"
		else
			flash.notice = "Signed in!"
			sign_in_and_redirect manager
      session[:omniauth_manager_authentication_id] = authentication.id
		end

	end

	def create_user(omniauth)
		user, authentication = User.from_omniauth(omniauth)
		if user.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect user
      session[:omniauth_user_authentication_id] = authentication.id
    else
      flash[:alert] = authentication.provider.humanize + " cannot be used to sign-up on Optyn as the email address is already in use. Please sign up with a different email."
			redirect_to new_user_registration_path
		end
	end

	def nullify_omniauth_user_type
		session[:omniauth_user] = nil
		session[:omniauth_manager] = nil
	end

	def after_sign_in_path_for(resource)
		return merchants_root_path if current_merchants_manager
		super
	end
end
