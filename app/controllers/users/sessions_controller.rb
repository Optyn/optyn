class Users::SessionsController < Devise::SessionsController
#	before_filter :require_manager_logged_out

	def new
		session[:omniauth_manager] = nil
    session[:omniauth_user] = true
    super
	end
end