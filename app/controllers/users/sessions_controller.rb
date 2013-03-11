class Users::SessionsController < Devise::SessionsController
  before_filter :require_no_consumer

  def create
    super
  end
  
  def new
    super
    session[:manager]=nil
    session[:user]=true
  end
end