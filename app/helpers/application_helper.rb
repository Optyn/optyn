module ApplicationHelper
  def user_present?
    user_signed_in? || merchants_manager_signed_in?
  end

end
