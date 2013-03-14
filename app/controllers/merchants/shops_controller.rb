class Merchants::ShopsController < ApplicationController

	def index
	end

	def edit
		@shop = Shop.find(params[:id])
	end

	def update
		@shop = Shop.find(params[:id])
		if @shop.update_attributes(params[:shop])
			flash[:notice] = "Shop details updated successfully"
      redirect_to root_path
    else
      @shop_errors = @shop.errors
      render :action => :edit
    end
	end
end