module ApplicationHelper
  def user_present?
    user_signed_in? || merchant_signed_in?
  end
end
