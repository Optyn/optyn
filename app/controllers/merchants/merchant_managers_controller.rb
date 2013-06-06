class Merchants::MerchantManagersController < Merchants::BaseController
  def show_managers
    @managers = current_merchants_manager.shop.managers
  end
  
  def add_manager
    @shop = current_merchants_manager.shop
    @manager = current_merchants_manager.children.build
  end

  def create_new_manager
    @manager = Manager.new(params[:manager])

    if @manager.save
      flash[:notice] = "New manager added successfully"
      redirect_to merchants_managers_list_path
    else
      @shop = current_merchants_manager.shop
      render 'add_manager'
    end
  end
end
