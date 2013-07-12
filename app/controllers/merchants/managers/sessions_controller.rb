class Merchants::Managers::SessionsController < Devise::SessionsController
  layout 'merchants'

  before_filter :redirect_to_user_session, only: [:new, :create]
  #before_filter :require_customer_logged_out

  def new
    session[:omniauth_manager] = true
    session[:omniauth_user] = nil
    super
  end

  def destroy
  	super
  	reset_session
  end

  private
  def redirect_to_user_session
    redirect_to new_user_session_path
    false
  end
end