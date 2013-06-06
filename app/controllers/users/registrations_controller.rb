class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager_logged_out
  before_filter :redirect_to_account, only: [:profile, :update_profile]
  


  def new
  	session[:omniauth_manager] =nil
    session[:omniauth_user] =true
    super
  end

  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      if params[:cross_domain_login].present?
        @user_login = User.new
        @user = resource
        render "api/v1/oauth/login", layout: 'cross_domain' and return
      end
      respond_with resource
    end
  end

  
  def profile
  	@user = current_user
    @permissions_user = @user.permissions_users.present? ? @user.permissions_users : @user.build_permission_users
  end

  def update_profile
  	@user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile updated successfully"
      redirect_to connections_path
    else
      render 'edit'
    end
  end
end
