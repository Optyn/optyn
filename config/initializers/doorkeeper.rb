Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
    set_optyn_oauth_resource_type(params[:client_id])
    if optyn_oauth_resource_type_merchant_app?
      current_merchants_manager || (session[:user_return_to] = request.fullpath and redirect_to(api_login_path(redirect_uri: params[:redirect_uri], client_id: params[:client_id], format: params[:format], callback: params[:callback], "_" => params["_"] ))) #warden.authenticate!(:scope => :user)
    elsif optyn_oauth_resource_type_partner_app?
      current_reseller_partner || (session[:user_return_to] = request.fullpath and redirect_to(new_reseller_partner_session_path))
    else
      current_user || (session[:user_return_to] = request.fullpath and redirect_to(api_login_path(redirect_uri: params[:redirect_uri], client_id: params[:client_id], format: params[:format], callback: params[:callback], "_" => params["_"] ))) #warden.authenticate!(:scope => :user)
    end  
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  # admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
  # end

  resource_owner_from_credentials do
    if optyn_oauth_resource_type_merchant_app?
      warden.authenticate(:scope => :merchants_manager)
    elsif optyn_oauth_resource_type_partner_app?
      warden.authenticate(:scope => :reseller_partner)
    else  
      warden.authenticate!(:scope => :user)
    end
  end

  # Authorization Code expiration time (default 10 minutes).
  authorization_code_expires_in 2.hours

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours
  access_token_expires_in 2.months

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  # optional_scopes :write, :update
  default_scopes  :public

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for mor information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the test redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # test_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  skip_authorization do |resource_owner, client|
    true
     #client.superapp? or resource_owner.admin?
  end
end
