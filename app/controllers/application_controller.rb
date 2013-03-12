class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :is_shop_local_and_active?

  private
  def require_no_consumer
    redirect_to root_path if merchants_manager_signed_in?
  end

  def require_customer_logged_out
    if user_signed_in?
      flash[:alert] = "You are already logged in"
      redirect_to root_path 
    end
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

  def after_sign_in_path_for(resource)
    flash[:notice] = "Signed in successfully"
    if current_user.zip_prompted?
      redirect_to connections_path
    else
      redirect_to new_user_zip_path
    end
    
  end
end
