module TrackingServices
  class Opens
    include HTTParty

    def self.track(token)
      response = HTTParty.get(SiteConfig.track_app_base_url + SiteConfig.simple_delivery.open_path + "/#{token.to_s}")
    end
  end
end