class Users::ZipsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @user = current_user
  end

  def create
    @user = current_user
    @user.attributes = params[:user]
    if @user.create_or_update_zips(params[:user])
      redirect_to root_path
    else
      render 'new'
    end
  end
end