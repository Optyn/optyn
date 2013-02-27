class Merchants::Managers::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager
  
  def new
    session[:manager]=true
    session[:user]=nil
    @shop=Shop.new
    @shop.managers.build
  end

  def create 
    @shop = Shop.new(params[:shop_name])
    
    if !@shop.shop_already_exists? && @shop.save
      @shop.update_manager
      @shop.managers.first.create_authentication(params[:auth_id], params[:auth_provider]) if params[:auth_id].present?
      sign_in(@shop.managers.first)
      flash[:notice] = "Merchant account created successfully"
      redirect_to root_path
    else
      @omniauth={:uid => params[:auth_id],:provider => params[:auth_provider]} if params[:auth_id].present?
      @shop.errors[:base] << "Business with entered details exists already" if @shop.shop_already_exists?
      render 'new'
    end

  end

end