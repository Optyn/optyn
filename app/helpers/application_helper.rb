module ApplicationHelper
  
  def user_present?
    user_signed_in? || merchants_manager_signed_in?
  end

  def has_locations?
    !(current_merchants_manager && current_merchants_manager.shop.locations.any?)
  end

end
