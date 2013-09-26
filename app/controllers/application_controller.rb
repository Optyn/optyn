require 'doorkeeper/resource_type_manager'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include Doorkeeper::ResourceTypeManager

  layout :switch_layout

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (:back), :alert => exception.message
  end

  alias_method :manager_signed_in?, :merchants_manager_signed_in?
  alias_method :current_manager, :current_merchants_manager

  helper_method :manager_signed_in?, :current_manager

  private
  def require_manager_logged_out
    if manager_signed_in?
      flash[:alert] = "You are already logged in"
      redirect_to merchants_root_path
    end
  end

  def redirect_to_account
    if !current_user.blank? && !current_user.email.present?
      flash[:notice] = "Please enter your email to proceed with Optyn."
      redirect_to edit_user_registration_path
    end
  end

  def require_customer_logged_out
    if user_signed_in?
      flash[:alert] = "You are already logged in"
      redirect_to consumers_root_path
    end
  end

  def require_not_logged_in
    if manager_signed_in?
      return redirect_to(merchants_root_path) && false
    end

    if user_signed_in?
      return redirect_to(consumers_root_path) && false
    end
  end

  def require_manager
    redirect_to root_path if !merchants_manager_signed_in?
  end

  def require_user
    redirect_to root_path unless user_signed_in?
  end

  def after_sign_in_path_for(resource)
    if session[:user_return_to].present?
      return session[:user_return_to]
    end

    flash[:notice] = "Signed in successfully"
    if admin_signed_in?
      '/admin'
    elsif user_signed_in?
      consumers_root_path
    elsif manager_signed_in?
      merchants_root_path
    end
  end

  def clear_session_anyone_logged_in
    session['warden.user.merchants_manager.key'] = nil
    session['warden.user.user.key'] = nil
  end

  def switch_layout
    user_signed_in? || manager_signed_in? ? 'base' : 'application'
  end
end
