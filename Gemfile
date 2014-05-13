source 'https://rubygems.org'

#Define the ruby version
ruby '1.9.3'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'cancan'
gem 'config_reader', '0.0.8' #ENV specific configuration
gem 'google-analytics-rails'
gem 'unicorn'
gem 'haml'
gem 'haml-rails'
gem 'devise'
gem 'devise-async'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin'
gem 'rails_admin'
gem 'client_side_validations'
gem 'doorkeeper', '~> 0.7.2'
gem 'oauth2'
gem 'carrierwave'
gem 'rmagick', '2.13.1'
gem "fog"
gem 'localtunnel'
gem 'chosen-rails'
gem 'kaminari'
gem 'newrelic_rpm'
gem 'geocoder'
gem 'whenever'
gem "imgkit", "~> 1.3.10"
gem 'remotipart', '~> 1.2'

# gems for stripe payment
gem 'stripe'
gem 'chronic', :require => 'chronic'
gem 'airbrake'
gem "state_machine", "~> 1.2.0"
gem "uuidtools"
gem 'redis'
gem 'redis-store'
gem 'redis-rails'

#email sending and accessing web api through amazon ses
gem 'aws-ses', :require => 'aws/ses'
gem 'aws-sdk'

#email sending and accessing web api using sendgrid
gem 'sendgrid'
gem 'sendgrid_toolkit', '>= 1.1.1'

gem 'rack-ssl-enforcer'
gem 'sitemap_generator'
gem 'phony_rails'
gem "acts_as_paranoid", "~>0.4.0"
gem 'feedzirra'
gem 'rabl'
gem 'oj'

gem 'pdfkit' #for pdf generation
gem 'rqrcode-with-patches' #for QR code
gem 'mini_magick'
gem "koala", "~> 1.8.0rc1" #for Facebook integration
gem 'social-share-button'
gem 'httparty'
gem "ckeditor"
gem 'premailer'
gem "intercom-rails"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # gem 'therubyracer', :platforms => :ruby
  # gem "less-rails"
  gem 'compass-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass', '~> 2.3.1.2'
  gem 'awesome_print'
  gem 'turbo-sprockets-rails3'
end

gem 'jquery-rails'

gem 'god'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'sidekiq-benchmark'
gem 'sidekiq-limit_fetch'

gem "gretel"
gem 'shortly'

#INFO:for test only, remove it later
# gem "http_logger"


group :development do
  gem 'thin'
  gem 'sextant'
  gem 'pry'
  gem 'debugger'
  gem 'quiet_assets'
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano-unicorn', :require => false
  gem 'rails-erd'
  #gem "capistrano-resque", "~> 0.1.0"
  gem "mailcatcher"
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem "erb2haml"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
