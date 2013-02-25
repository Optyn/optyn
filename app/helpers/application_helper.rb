module ApplicationHelper
  def user_present?
    user_signed_in? || manager_signed_in?
  end

end
