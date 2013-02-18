OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	# provider :developer unless Rails.env.production?
  # provider :twitter, 'Acwx2jBkCCbFZHkW8wEubQ', 'zGevh2gWCvuW2h2BXPe84arg5sm7A4bEWmxvHddno'
  provider :twitter, 'Acwx2jBkCCbFZHkW8wEubQ', 'zGevh2gWCvuW2h2BXPe84arg5sm7A4bEWmxvHddno'
  # provider :facebook, SiteConfig.facebook_app_id, SiteConfig.facebook_app_secret
  # provider :google_oauth2, SiteConfig.google_client_id, SiteConfig.google_client_secret

  #401 unauthorised error
  # OmniAuth.config.on_failure = Proc.new { |env|
  #     OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  # }
end