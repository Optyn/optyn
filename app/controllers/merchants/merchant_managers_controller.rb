class Merchants::MerchantManagersController < Merchants::BaseController
  def show_managers
    @managers = current_merchants_manager.shop.managers
  end
end
