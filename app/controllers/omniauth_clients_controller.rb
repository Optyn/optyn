class OmniauthClientsController < ApplicationController
	after_filter :nullify_omniauth_user_type, except: [:login_type, :create_for_twitter, :create]

  #SET THE session[:omniauth_manager] = true BY DEFAULT, REMOVE THE FILTER BELOW ONCE THE SOCIAL LOGIN FOR USER IS ACTIVATED 
  before_filter :set_omniauth_manager_in_session, only: [:create, :create_for_twitter]

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

  def create_for_twitter
  	if session[:omniauth_user].present?
  		begin
  			User.transaction do
		  		@user = User.new(params[:user].except(:authentication))
		  		@user.skip_password = true
		  		@user.save
		  		@authentication = @user.authentications.build(params[:user][:authentication])
		  		@authentication.save
	  	  end
	  	  sign_in @user
	  		session[:omniauth_user_authentication_id] = @authentication.id
	  		redirect_to after_sign_in_path_for(@user)
	  		nullify_omniauth_user_type
  		rescue ActiveRecord::RecordInvalid => e
  			flash[:alert] = "Email is already in use."
 			render action: "new_twitter" 			
  		end	
  	end
  end

	private

	def create_manager(omniauth)
		@manager, @authentication = Manager.create_from_omniauth(omniauth)

		if @manager.new_record?
			@shop = Shop.new
			@shop.managers.build(:name => @manager.name, :email => @manager.email)
			@omniauth = omniauth
			render :template => "merchants/managers/registrations/new"
		else
			flash.notice = "Signed in!"
			sign_in_and_redirect @manager
      session[:omniauth_manager_authentication_id] = @authentication.id
      nullify_omniauth_user_type
		end

	end

	def create_user(omniauth)
		@user, @authentication = User.from_omniauth(omniauth)

		if @user.persisted?
			flash.notice = "Signed in!"
			sign_in_and_redirect @user
      session[:omniauth_user_authentication_id] = @authentication.id
      nullify_omniauth_user_type
    else
      flash[:alert] =  "Could not create an account without an email. Please enter your email."
			render :action => "new_twitter"
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

  def set_omniauth_manager_in_session
    session[:omniauth_manager] = true
    session[:omniauth_user] = nil
  end
end
