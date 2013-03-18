class Merchants::ShopsController < BaseController

	def index
	end

	def edit
		@shop = current_shop
	end

	def update
		@shop = current_shop
		if @shop.update_attributes(params[:shop])
			flash[:notice] = "Shop details updated successfully"
      redirect_to root_path
    else
      @shop_errors = @shop.errors
      render :action => :edit
    end
	end
end