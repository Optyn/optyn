class Users::SessionsController < Devise::SessionsController
  #before_filter :require_manager_logged_out
  respond_to :html, :json

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
    sign_in(resource_name, resource)
    respond_to do |format|
      format.html {respond_with resource, :location => after_sign_in_path_for(resource)}
      format.json{render(status: :created, json: {data: {user: resource.as_json(only: [:name])}})}
    end
  end
end
