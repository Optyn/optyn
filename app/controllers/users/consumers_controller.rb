class Users::ConsumersController < ApplicationController
  before_filter :require_consumer

  def new_zip_code
    @user=current_user
  end

  def add_zip_code
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to root_path
    else
      render 'new_zip_code'
    end

  end

end
