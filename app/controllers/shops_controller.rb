class ShopsController < ApplicationController
  layout 'flat'
  def show
    @shop  = Shop.find_by_identifier(params[:identifier])
    redirect_to(new_user_session_path, notice: "Could not find the shop you are looking for.")  if @shop.blank?
  end
end
