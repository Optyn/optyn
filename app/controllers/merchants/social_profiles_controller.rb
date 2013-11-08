class Merchants::SocialProfilesController < Merchants::BaseController
  
  def index     
  end

  def new
    @social_profile = SocialProfile.new
  end

  def create
    @error_hash = []
    flag = true
    
    SocialProfile::SOCIAL_PROFILES.each do |k, v| 
      @social_profile = SocialProfile.where(:sp_type => v.to_i, :shop_id => current_shop.id)
      if not @social_profile.blank?
        @social_profile = @social_profile.first
        @social_profile.sp_link = params[k]
      else
        next if params[k].blank?
        @social_profile = SocialProfile.new(:sp_type => v.to_i, :sp_link => params[k])
        @social_profile.shop_id = current_shop.id
      end

      if not @social_profile.save
        flag = false
        @error_hash.push("Link for #{k} #{@social_profile.errors.messages[:sp_link].first}")
      end
    end

    if flag
      redirect_to merchants_social_profile_path(current_shop.id), :notice => "Social Profiles added successfully."
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
