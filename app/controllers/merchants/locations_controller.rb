class Merchants::LocationsController < Merchants::BaseController
  skip_before_filter :active_subscription?, :only => [:index]
  before_filter :is_current_manager_owner?, :only =>[:new]
  def index
    @locations = current_shop.locations
  end

  def new
    @location = current_shop.locations.build
  end

  def create
    @location = current_shop.locations.new(params[:location])
    if @location.save
      GeoFinder.perform_async(@location.id)
      flash[:notice] = "Location added successfully"
      redirect_to merchants_locations_path
    else
      render 'new'
    end

  end
  
  def edit 
    @location = current_shop.locations.find(params[:id])
  end

  def update 
    @location = current_shop.locations.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = "Location updated successfully"
      redirect_to merchants_locations_path
    else
      render 'edit'
    end
  end

  def destroy
    @location = current_shop.locations.find(params[:id])
    @location.destroy
    flash[:notice] = "Location removed successfully"
    redirect_to merchants_locations_path
  end


end
