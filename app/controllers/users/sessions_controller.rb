class Users::SessionsController < Devise::SessionsController
	#before_filter :require_manager_logged_out

	def new
		session[:omniauth_manager] = nil
    session[:omniauth_user] = true
    super
	end


  def create
    params[:email] = params[:user][:email]
    unless User.find_by_email(params[:user][:email])
      auth_options = {scope: :merchants_manager, recall: 'sessions#new'}
      resource_name = :merchants_manager
      warden.config[:default_scope] = :merchants_manager
      params[:merchants_manager] = params.delete(:user)
      resource_name = :merchants_manager
    else
      resource_name = :user
      auth_options = {scope: :user, recall: 'sessions#new'}
    end
    resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end
end
