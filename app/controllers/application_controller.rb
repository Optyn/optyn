class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_consumer
    redirect_to root_path if merchants_manager_signed_in?
  end

  def require_manager
    redirect_to root_path if user_signed_in?
  end

end
