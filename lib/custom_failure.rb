class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :user && params[:cross_domain_login].present?
      api_login_path
    elsif warden_options[:scope] == :user || warden_options[:scope] == :merchants_manager
      flash[:alert] = i18n_message(:invalid)
      new_user_session_path(email: params[:email])
    else
      super
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end