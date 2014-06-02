module TrackingServices
  class Messages
    include HTTParty

    def self.qr_code(token)
      response = HTTParty.get(SiteConfig.track_app_base_url + SiteConfig.simple_delivery.qr_code_path + "/#{token.to_s}")
    end

  end
end