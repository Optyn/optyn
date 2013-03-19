if Rails.env == "production" ||  Rails.env == "staging"
	CarrierWave.configure do |config|
		config.storage = :fog
	  config.fog_credentials = {
	    :provider               => 'AWS',                        # required
	    :aws_access_key_id      => 'AKIAJO7WB66NE2EDUV2Q',                        # required
	    :aws_secret_access_key  => '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'
	  }
	  config.fog_directory  = SiteConfig.bucket                     # required
	  config.fog_public     = true                                  # optional, defaults to true
	  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
	end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
end