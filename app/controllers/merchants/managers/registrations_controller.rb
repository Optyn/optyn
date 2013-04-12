class Merchants::Managers::RegistrationsController < Devise::RegistrationsController
  layout 'merchants'

  include MerchantSessionsRedirector

  before_filter :require_customer_logged_out
  
  def new
    session[:omniauth_manager]=true
    session[:omniauth_user]=nil
    @shop=Shop.new
    @shop.managers.build
  end

  def create 
    @shop = Shop.new(params[:shop_name])
    
    if !@shop.shop_already_exists? && @shop.save
      @shop.update_manager
      @shop.managers.first.create_authentication(params[:auth_id], params[:auth_provider]) if params[:auth_id].present?
      flash[:notice] = "You updated your account successfully, but we need to verify your new email address. Please check your email and click on the confirm link to finalize confirming your new email address."
      redirect_to thankyou_path
    else
      @omniauth={:uid => params[:auth_id],:provider => params[:auth_provider]} if params[:auth_id].present?
      @shop.errors[:base] << "Business with entered details exists already" if @shop.shop_already_exists?
      render 'new'
    end

  end


end