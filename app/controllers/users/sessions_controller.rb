class Users::SessionsController < Devise::SessionsController
  #before_filter :require_manager_logged_out
  respond_to :html, :json
  prepend_before_filter :require_no_authentication, :only => [:new, :create, :authenticate_with_email]
  prepend_before_filter :allow_params_authentication!, :only => [:create, :authenticate_with_email]
  prepend_before_filter :increment_email_box_click_count, :only => [:authenticate_with_email]
  prepend_before_filter :require_not_logged_in, :except => [:destroy] 

  def new
    session[:omniauth_manager] = nil
    session[:omniauth_user] = true

    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)

    respond_to do |format|
      format.html { super }
      format.json { render(status: :ok) }
    end
  end


  def create
    params[:email] = params[:user][:email]
    unless Manager.find_by_email(params[:user][:email])
      resource_name = :user
      auth_options = {scope: :user, recall: 'sessions#new'}
    else
      auth_options = {scope: :merchants_manager, recall: 'sessions#new'}
      resource_name = :merchants_manager
      warden.config[:default_scope] = :merchants_manager
      params[:merchants_manager] = params.delete(:user)
      resource_name = :merchants_manager
    end
    clear_session_anyone_logged_in
    resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource)
    respond_to do |format|
      format.html { respond_with resource, :location => after_sign_in_path_for(resource) }
      # API RESPONSE FOR MANAGER GENERATE ME_ACCESS_TOKEN IF it's partner 
      format.json { render(status: :created) }
    end
  end

  def authenticate_with_email
    if params[:user][:email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      @user = User.find_by_email(params[:user][:email])
      @user = sudo_registration unless @user.present?

      #this code section is called when useris coming from public page of shop
      if params[:next].present? and params[:from] == "public_page"
        flash[:alert] = "Successfully Subscribed"
        redirect_to public_shop_path and return
      end

      sign_in @user
      session[:user_return_to] = nil

      respond_to do |format|
        format.json { render(status: :created) }

        format.any { render text: "Only HTML and JSON supported" }
      end
    else
      #this code section is called when useris coming from public page of shop
      if params[:next].present? and params[:from] == "public_page"
        @shop = Shop.for_uuid(params[:uuid])
        @user.make_connection_if!(@shop)
        flash[:alert] = "Please check your email address"
        redirect_to "#{params[:next]}" and return
      end

      respond_to do |format|
        @user = User.new
        @user.errors.add(:base, "Please check your email address")
        format.json { render(status: :ok) } 
      end
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
      @user.show_password = true
      @shop = Shop.by_app_id(params[:app_id]) rescue Shop.for_uuid(params[:uuid])
      @user.show_shop = true
      @user.shop_identifier = @shop.id
      @user.save(validate: false)
    end
    #return the user
    @user
  end

  def increment_email_box_click_count
    @shop = Shop.by_app_id(params[:app_id])
    @shop.increment_email_box_click_count if @shop.present?
  end
end
