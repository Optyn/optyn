## Gmail Service Settings ## 
#unless Rails.env.development?
#	ActionMailer::Base.delivery_method = :smtp
#	ActionMailer::Base.smtp_settings = {
#		:tls => true,
#		:enable_starttls_auto => false,
#		:port => 465,
#		:address => "smtp.gmail.com",
#		:domain => 'optyn.com',
#		:user_name => "services@optyn.com",
#		:password => "7cd5a95!",
#		:authentication => :plain,
#		:openssl_verify_mode => 'none'
#	}
#end

## Amazon SES Settings ## 
# ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
#    :access_key_id     => 'AKIAJO7WB66NE2EDUV2Q',
#    :secret_access_key => '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'

## Sendgrid Settings
if Rails.env.development?
  ActionMailer::Base.smtp_settings = { :address => "localhost", :port => 1025 }
else
  require File.expand_path('../site_config', __FILE__)
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => 587,
    :domain => "simple-send.com",
    :authentication => :plain,
    :user_name => SiteConfig.send_grid_username,
    :password => SiteConfig.send_grid_password,
    :enable_starttls_auto => true
  }
end