OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	# provider :developer unless Rails.env.production?
  provider :twitter, SiteConfig.twitter_consumer_key, SiteConfig.twitter_consumer_secret,	:scope => 'profile_image, screen_name'
  provider :facebook, SiteConfig.facebook_app_key, SiteConfig.facebook_app_secret#,	:scope => 'email,user_birthday,secure_image_url'
  provider :google_oauth2, SiteConfig.google_client_id, SiteConfig.google_client_secret, {
             :scope => "userinfo.email,userinfo.profile,plus.me,http://gdata.youtube.com",
           }
  provider :linkedin, SiteConfig.linkedin_api_key, SiteConfig.linkedin_secret_key
  #401 unauthorised error
  OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
end