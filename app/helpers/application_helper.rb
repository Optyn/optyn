module ApplicationHelper
  
  def user_present?
    user_signed_in? || merchants_manager_signed_in?
  end
  alias_method :someone_logged_in?, :user_present?

  def has_locations?
    manager = current_merchants_manager
    manager && manager.shop.stype=="local" && !manager.shop.locations.any?
  end

  def is_shop_online?(shop)
    shop.is_online?
  end

  def is_shop_local?(shop)
    shop.is_local?
  end
  
  def user_signed_out?
    user_present? == false
  end
end
