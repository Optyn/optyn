class Merchants::Managers::SessionsController < Devise::SessionsController
  before_filter :require_customer_logged_out

  include MerchantSessionsRedirector

  def new
    session[:omniauth_manager] = true
    session[:omniauth_user] = nil
    super
  end

  def destroy
  	super
  	reset_session
  end
end