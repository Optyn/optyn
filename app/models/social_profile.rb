class SocialProfile < ActiveRecord::Base
  belongs_to :shop
  attr_accessible :sp_link, :sp_type, :shop_id

  SOCIAL_PROFILES = {1 => "facebook", 2 => "twitter", 3 => "linkedin"}
  
  validates :sp_link, presence: true, uniqueness: {scope: :shop_id}, format: {with: URI::regexp(%w(http https))}
  validates :sp_type, uniqueness: {scope: :shop_id}, unless: Proc.new{|s| s.sp_link.blank?}

  def self.all_types_map(owner_shop_id=nil)
    profiles = {}
    
    SOCIAL_PROFILES.each_pair do |key, value|
      profiles[key] = new(sp_type: key, shop_id:  owner_shop_id)
    end 

    profiles
  end
end   
