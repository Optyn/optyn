class Merchants::Managers::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager
  
  def new
    session[:manager]=true
    session[:user]=nil
    @shop=Shop.new
    @shop.managers.build
    @shop.locations.build
  end

  def create 
    @shop = Shop.new(filter_shop_params)
    
    if !@shop.shop_already_exists? && @shop.save
      @shop.update_manager
      sign_in(@shop.managers.first)
      redirect_to root_path
    else
      @shop.locations.build if @shop.stype=="online"
      @shop.errors[:base] << "Business with entered details exists already" if @shop.shop_already_exists?
      render 'new'
    end

  end

  private
  def filter_shop_params()
    if 'online' == params[:shop_name][:stype]
     return params[:shop_name].except(:locations_attributes) 
    end 

    params[:shop_name]   
  end

end