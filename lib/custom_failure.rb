class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :user && params[:cross_domain_login].present?
      api_login_path
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