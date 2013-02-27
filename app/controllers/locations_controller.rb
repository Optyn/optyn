class LocationsController < ApplicationController
  before_filter :load_shop
  before_filter :require_manager 

  def index
    @locations=@shop.locations
  end

  def new
    @location=@shop.locations.build
  end

  def create
    @location=@shop.locations.new(params[:location])

    if @location.save
      flash[:notice]="Location added successfully"
      redirect_to locations_path
    else
      render 'new'
    end

  end
  
  def edit 
    @location=@shop.locations.find(params[:id])
  end

  def update 
    @location=@shop.locations.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice]="Location updated successfully"
      redirect_to locations_path
    else
      render 'edit'
    end
  end

  def destroy
    @location=@shop.locations.find(params[:id])
    @location.destroy
    flash[:notice]="Location removed successfully"
    redirect_to root_path
  end


  protected
    def load_shop
      @shop=current_merchants_manager.shop
    end

end
