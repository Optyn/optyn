class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :user && params[:cross_domain_login].present?
      api_login_path
    elsif warden_options[:scope] == :user || warden_options[:scope] == :merchants_manager

      if (params[:user].present? || params[:merchants_manager].present?) && (instance = (User.find_by_email(params[:user][:email]) || Manager.find_by_email(params[:merchants_manager][:email]))).present?  && instance.authentications.present?
        provider = instance.authentications.last.provider.gsub(/_oauth2/, '').humanize
        flash[:alert] = "We have found that you are registered with #{provider} in Optyn. Please login appropriately."
      else
        flash[:alert] = i18n_message(:invalid)
      end

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