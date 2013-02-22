class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :require_consumer
  def create
    super
  end

  def new
    session[:manager]=nil
    session[:user]=true
  end
end