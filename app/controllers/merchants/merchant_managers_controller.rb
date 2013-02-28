class Merchants::MerchantManagersController < ApplicationController
  before_filter :require_manager

  def show_managers
    @managers=current_merchants_manager.shop.managers
  end

end
