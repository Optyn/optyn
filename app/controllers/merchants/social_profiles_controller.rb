class Merchants::SocialProfilesController < Merchants::BaseController
  
  def index     
  end

  def new
    @social_profile = SocialProfile.new
  end

  def create
    @social_profile = SocialProfile.new(params[:social_profile])
    @social_profile.shop_id = current_shop.id
    if @social_profile.save
      redirect_to merchants_social_profile_path(current_shop.id), :notice => "Social Profile inserted successfully."
    else
      render 'new'
    end
  end

  def edit
    @social_profile = SocialProfile.find(params[:id])
  end

  def update
    @social_profile = SocialProfile.find(params[:id])
    @social_profile.shop_id = current_shop.id
    
    if @social_profile.update_attributes(params[:social_profile])
      redirect_to merchants_social_profile_path(current_shop.id), :notice => "Social Profile updated successfully."
    else
      render 'edit'
    end
  end

  def show
    @social_profiles = SocialProfile.where(:shop_id => params[:id])
  end

  def delete
  end
end
