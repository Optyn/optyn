OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	# provider :developer unless Rails.env.production?
  provider :twitter, SiteConfig.twitter_consumer_key, SiteConfig.twitter_consumer_secret
  provider :facebook, SiteConfig.facebook_app_id, SiteConfig.facebook_app_secret
  provider :google_oauth2, SiteConfig.google_client_id, SiteConfig.google_client_secret
end