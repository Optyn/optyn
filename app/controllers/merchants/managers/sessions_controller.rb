class Managers::SessionsController < Devise::SessionsController
  before_filter :require_manager
  
  def new
    super
    session[:manager]=true
    session[:user]=nil
  end
end