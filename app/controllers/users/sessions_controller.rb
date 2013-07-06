class Users::SessionsController < Devise::SessionsController
  #before_filter :require_manager_logged_out
  respond_to :html, :json
  prepend_before_filter :require_no_authentication, :only => [:new, :create, :authenticate_with_email]
  prepend_before_filter :allow_params_authentication!, :only => [:create, :authenticate_with_email]

  def new
    session[:omniauth_manager] = nil
    session[:omniauth_user] = true

    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)

    respond_to do |format|
      format.html { super }
      format.json { render(status: :ok, json: {data: {authenticity_token: form_authenticity_token, error: nil}}) }
      format.any { render text: "Only HTML and JSON supported" }
    end
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
    sign_in(resource)
    respond_to do |format|
      format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
      format.json { render(status: :created, json: {data: {user: resource.as_json(only: [:name])}}) }
    end
  end

  def authenticate_with_email
    @user = User.find_by_email(params[:user][:email])
    sudo_registration unless @user.present?

    sign_in @user
    session[:user_return_to] = nil
    respond_to do |format|
      format.json {
        json_data = {data: {user: @user.as_json(only: [:name])}}.to_json
        if params[:callback].present?
          render text: "#{params[:callback]}('#{json_data}')"
        else
          render(json: json_data, status: created)
        end

      }

      format.any { render text: "Only HTML and JSON supported" }
    end
  end

  private
  def sudo_registration
    @user = User.new(params[:user])
    passwd = Devise.friendly_token.first(8)
    @user.password = passwd
    @user.password_confirmation = passwd

    saved = @user.save
    @user.errors.delete(:name)

    if !saved && @user.errors.blank?
      @user.save(validate: false)
      @user.show_password = true
    end
  end
end
