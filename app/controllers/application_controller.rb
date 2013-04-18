class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :is_shop_local_and_active?

  alias_method :manager_signed_in?, :merchants_manager_signed_in?
  alias_method :current_manager, :current_merchants_manager

  private
  def require_manager_logged_out
    if manager_signed_in?
      flash[:alert] = "You are already logged in"
      redirect_to merchants_root_path
    end
  end

  def redirect_to_account
		if !current_user.blank? && !current_user.email.present?
			redirect_to edit_user_registration_path
		end
  end

  

  def require_customer_logged_out
    if user_signed_in?
      flash[:alert] = "You are already logged in"
      redirect_to customers_root_path
    end
  end

  def require_not_logged_in
    if manager_signed_in?
      return redirect_to(merchants_root_path) && false
    end

    if user_signed_in?
      return redirect_to(customers_root_path) && false
    end
  end

  def require_manager
    redirect_to root_path if !merchants_manager_signed_in?
  end

  def require_user
    redirect_to root_path unless user_signed_in?
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
    if session[:user_return_to].present?
      return session[:user_return_to]
    end

    flash[:notice] = "Signed in successfully"
    if current_admin
      '/admin'
    elsif current_user.zip_prompted?
      connections_path
    else
      new_user_zip_path
    end
  end
end
