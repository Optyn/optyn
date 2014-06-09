class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :profile, :update_profile]
  before_filter :require_manager_logged_out
  before_filter :redirect_to_account, only: [:profile, :update_profile]


  def new
    session[:omniauth_manager] =nil
    session[:omniauth_user] =true

    resource = build_resource({})
    #respond_with resource

    respond_to do |format|
      format.html{respond_with resource}
      format.json { render(status: :ok, json: {data: {authenticity_token: form_authenticity_token, error: nil}}) }
      format.any { render text: "Only HTML and JSON supported" }
    end
  end

  def create
    build_resource

    if (@shop = Shop.by_app_id(params[:app_id])).present?
      resource.show_shop = true
      resource.shop_identifier = @shop.id
    end

    clear_session_anyone_logged_in

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        #respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end

      respond_to do |format|
        format.html {respond_with resource, :location => after_sign_up_path_for(resource)}
        format.json{render(status: :created, json: {data: {user: resource.as_json(only: [:name])}})}
      end
    else
      clean_up_passwords resource
      if params[:cross_domain_login].present?
        @user_login = User.new
        @user = resource
        render "api/v1/optyn_button/login", layout: 'cross_domain' and return
      end

      respond_to do |format|
        format.html {respond_with resource}
        format.json{render(status: :unprocessable_entity, json: {data: {user: resource.as_json(only: [:name, :email]), errors: resource.errors.full_messages.as_json}})}
      end
    end
  end


  def profile
    @user = current_user
    # @permissions_user = @user.permissions_users.present? ? @user.permissions_users : @user.build_permission_users
  end

  def update_profile
    #render layout: 'merchants'
    @user = current_user
    @user.attributes = params[:user].except(:birth_date)

    if params[:user][:birth_date].present?
      begin
        @user.birth_date = Time.strptime(params[:user][:birth_date], '%m/%d/%Y')
      rescue
        @user.errors[:birth_date] = "invalid"
      end
    else
      @user.birth_date = nil
    end

    if @user.save
      # @permissions_user = @user.permissions_users.present? ? @user.permissions_users : @user.build_permission_users
      flash.now[:notice] = "Profile updated successfully"
      render action: "profile"
    else
      render 'edit'
    end
  end


  def edit
  end

end
