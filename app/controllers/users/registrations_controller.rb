class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager_logged_out

  def new
  	session[:omniauth_manager] =nil
    session[:omniauth_user] =true
    super
  end
  
  def profile
  	@user = current_user
  end
  
  def update_profile
  	@user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice]="Profile updated successfully"
      redirect_to connections_path
    else
      render 'edit'
    end
  end
end
