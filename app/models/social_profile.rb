class SocialProfile < ActiveRecord::Base
  belongs_to :shop
  attr_accessible :sp_link, :sp_type, :shop_id

  SOCIAL_PROFILES = {1 => "facebook", 2 => "twitter", 3 => "linkedin"}
  
  validates :sp_link, presence: true, uniqueness: {scope: :shop_id}
  validate :parse_sp_link 
  validates :sp_type, uniqueness: {scope: :shop_id}, unless: Proc.new{|s| s.sp_link.blank?}

  after_save :add_http_if_missing

  def self.all_types_map(owner_shop_id=nil)
    profiles = {}
    
    SOCIAL_PROFILES.each_pair do |key, value|
      profiles[key] = new(sp_type: key, shop_id:  owner_shop_id)
    end 

    profiles
  end

  private
    def parse_sp_link
      unless errors.include?(:sp_link)
        begin
          URI.parse(self.sp_link)
        rescue
          self.errors.add(:sp_link, "is invalid. Here is an example: http://example.com")
        end
      end
    end

    def add_http_if_missing
      existing_sp_link = URI.parse(self.sp_link).to_s
      binding.pry
      if !existing_sp_link.include?('http://') && !existing_sp_link.include?('https://')
        self.sp_link = "http://" + existing_sp_link
        self.save
      end
    end
end   
