class Merchants::ShopsController < Merchants::BaseController

	def index
	end

	def edit
		@shop = current_shop
	end

	def update
		@shop = current_shop
		if @shop.update_attributes(params[:shop])
			flash[:notice] = "Shop details updated successfully"
      redirect_to merchants_shop_path
    else
      @shop_errors = @shop.errors
      render :action => :edit
    end
	end
	
	def show
		@shop = current_shop
	end
end