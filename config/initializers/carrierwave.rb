#if Rails.env == "production" ||  Rails.env == "staging"
require File.expand_path('../site_config', __FILE__)

	CarrierWave.configure do |config|
		config.storage = :fog
	  config.fog_credentials = {
	    :provider               => 'AWS',                        # required
	    :aws_access_key_id      => SiteConfig.aws_access_key_id,                        # required
	    :aws_secret_access_key  => SiteConfig.aws_secret_access_key,
	    :persistent => false
	  }
	  config.fog_directory  = SiteConfig.bucket                     # required
	  config.fog_public     = true                                  # optional, defaults to true
	  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
	end
#else
#  CarrierWave.configure do |config|
#    config.storage = :file
#  end
#end