module TrackingServices
  class Links
    include HTTParty

    def self.track(uit)
      response = HTTParty.get(SiteConfig.track_app_base_url + SiteConfig.simple_delivery.link_path + "?uit=#{uit.to_s}&from_optyn=true")
    end
  end
end