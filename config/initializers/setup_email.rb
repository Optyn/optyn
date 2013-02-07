ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :enable_starttls_auto => false,
  :port => 465,
  :address => "smtp.gmail.com",
  :domain => 'optyn.com',
  :user_name => "services@optyn.com",
  :password => "7cd5a95!",
  :authentication => :plain,
  :openssl_verify_mode => 'none'
}