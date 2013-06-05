module LocationsHelper
  def shop_address_components(shop)
    [shop.first_location_street_address, shop.first_location_city, shop.first_location_state_name, shop.first_location_zip]
  end
end