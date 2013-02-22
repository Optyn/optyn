class Managers::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager
  
  def new
    session[:manager]=true
    session[:user]=nil
    @shop=Shop.new
    @manager=@shop.managers.build
  end

  def create 
    if !Shop.shop_already_exists?(params[:shop_name][:name])
      @shop=Shop.create_shop(params[:shop_name])
      @manager=@shop.managers.new(params[:shop_name][:managers_attributes]['0'].merge({:owner=>true}))
      if @manager.valid? 
        @manager.save
        sign_in(@manager)
        redirect_to root_path
      else
        @shop.destroy
        render 'new'
      end
    else
      @manager.valid?
      render 'new'
    end
  end

end