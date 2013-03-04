class Users::RegistrationsController < Devise::RegistrationsController
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