class ShopTimezone
  def self.set_timezone(shop)
    timezone = (shop.time_zone.present? rescue nil) ? shop.time_zone : "Eastern Time (US & Canada)"
    Time.zone = timezone
  end
end