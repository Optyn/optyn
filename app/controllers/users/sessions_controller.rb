class Users::SessionsController < Devise::SessionsController
	before_filter :require_manager_logged_out

	def new
		session[:omniauth_manager] = nil
    session[:omniauth_user] = true
    super
	end


  def create
    super
    @user_login = User.new(params[:user])
  end

end
