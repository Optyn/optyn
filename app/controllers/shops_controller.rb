class ShopsController < ApplicationController
  def show
    @shop  = Shop.find_by_identifier(params[:identifier])
    redirect_to login_path if @shop.blank?
  end
end
