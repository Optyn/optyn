class Users::CrossDomianAuthenticationController < ApplicationController
#  doorkeeper_for :all
  layout "cross_domain"
  def login
    session[:omniauth_manager] = nil
    session[:omniauth_user] = true
  end

  def shop_profile
    
  end

end
