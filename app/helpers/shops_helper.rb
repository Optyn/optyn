module ShopsHelper
  def show_logo(shop, options={})
    shop.logo_img.present? ? image_tag(shop.logo_img.url, options) : "Please update your Logo"
  end

  def shop_name_with_city_state(shop)
    [shop.name, shop.first_location_city, shop.first_location_state_name].compact.join(", ")
  end
end
