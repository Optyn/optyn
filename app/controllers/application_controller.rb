class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :is_shop_local_and_active?

  def require_no_consumer
    redirect_to root_path if merchants_manager_signed_in?
  end

  def require_consumer_zip_code
    redirect_to new_user_zip_path if current_user && !current_user.zip_prompted?
  end

  def require_no_manager
    redirect_to root_path if user_signed_in?
  end

  def require_manager
    redirect_to root_path if !merchants_manager_signed_in?
  end

  def is_shop_local_and_active?
    current_merchants_manager.shop.is_subscription_active? if merchants_manager_signed_in?
  end

  def is_shop_local?(shop)
    
  end

  def require_shop_local_and_inactive
    redirect_to root_path if is_shop_local_and_active?
  end

end
