class Managers::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager
  
  def new
    session[:manager]=true
    session[:user]=nil
    @shop=Shop.new
    @shop.managers.build
    @shop.locations.build
  end

  def create 
    @shop=Shop.new(get_params(params))
    if !@shop.shop_already_exists? && @shop.valid? && @shop.save
      @shop.update_manager
      sign_in(@shop.managers.first)
      redirect_to root_path
    else
      @shop.locations.build if @shop.stype=="online"
      @shop.errors[:base] << "Business with entered details exists already" if @shop.shop_already_exists?
      render 'new'
    end
  end

  def get_params(params)
    if params[:shop_name][:stype]=='online'
      params[:shop_name].select {|k,v| k != "locations_attributes"}
    else
      params[:shop_name]
    end
  end

end