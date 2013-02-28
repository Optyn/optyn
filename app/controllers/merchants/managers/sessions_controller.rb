class Merchants::Managers::SessionsController < Devise::SessionsController
  before_filter :require_no_manager
  
  def new
    super
    session[:manager]=true
    session[:user]=nil
  end
end