class Merchants::SocialProfilesController < Merchants::BaseController
  
  def index
    @social_profiles = current_shop.with_missing_profiles
  end

  def add
    @social_profile = current_shop.social_profiles.build(sp_type: params[:id])
    
    render action: 'add', layout: false
  end

  def create
    @social_profile = current_shop.social_profiles.build(params[:social_profile])
    @social_profile.save!
    current_shop.reload
    @social_profiles = current_shop.with_missing_profiles
    render partial: "merchants/social_profiles/list"
  rescue ActiveRecord::RecordInvalid => e
    render template: 'merchants/social_profiles/add', status: :unprocessable_entity, layout: false
  end

  def edit
    @social_profile = SocialProfile.find(params[:id])
    @social_profile.sp_link = @social_profile.sp_link.to_s.gsub(/https?:\/\//, "")
    render layout: false
  end

  def update
    @social_profile = SocialProfile.find(params[:id])
    @social_profile.attributes = params[:social_profile]
    @social_profile.save!
    @social_profiles = current_shop.with_missing_profiles
    render partial: "merchants/social_profiles/list"
  rescue ActiveRecord::RecordInvalid => e
    render action: 'edit', layout: false, status: :unprocessable_entity
  end

  def destroy
    @social_profile = SocialProfile.find(params[:id])
    @social_profile.destroy
    redirect_to merchants_social_profiles_path
  end
end
