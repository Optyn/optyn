class ShopsController < ApplicationController
  def show
    @shop  = Shop.find_by_identifier(params[:identifier])
  end
end
