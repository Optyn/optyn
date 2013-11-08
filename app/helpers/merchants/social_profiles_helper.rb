module Merchants::SocialProfilesHelper
	def get_social_links_for_shop(type)
    t = SocialProfile::SOCIAL_PROFILES[type]
    sp = SocialProfile.where(:sp_type => t, :shop_id => current_shop.id)
    return (sp and sp.blank?) ? "" : sp.first.sp_link
  end
end
