class Merchants::Managers::RegistrationsController < Devise::RegistrationsController
  layout 'merchants'

  include MerchantSessionsRedirector

  before_filter :require_customer_logged_out
  
  def new
    session[:omniauth_manager] = true
    session[:omniauth_user] = nil
    @shop = Shop.new
    @shop.managers.build
  end

  def create 
    @shop = Shop.new(params[:shop_name])

    @manager = @shop.managers.first
    @manager.skip_password = true if params[:auth_id].present? && params[:auth_provider].present?

    if !@shop.shop_already_exists? && @shop.save
      @shop.update_manager
      @shop.managers.first.create_authentication(params[:auth_id], params[:auth_provider]) if params[:auth_id].present?
      sign_in(@shop.managers.first)
      flash[:notice] = "Merchant account created successfully"
      redirect_to after_sign_in_path_for(nil) 	
    else
      flash[:alert] = "Could not sign-up"
      @omniauth={:uid => params[:auth_id],:provider => params[:auth_provider]} if params[:auth_id].present?
      @shop.errors[:name] << "Business with entered details exists already" if @shop.shop_already_exists?
      render 'new'
    end

  end


end
