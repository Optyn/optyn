class SocialProfile < ActiveRecord::Base
  belongs_to :shop
  attr_accessible :sp_link, :sp_type

  SOCIAL_PROFILES = {"facebook" => 1, "twitter" => 2, "linkedin" => 3}

  validates_format_of :sp_link, :with => URI::regexp(%w(http https)), unless: Proc.new{|s| s.sp_link.blank?}
  
  validates_uniqueness_of :sp_link, :scope => [:shop_id], unless: Proc.new{|s| s.sp_link.blank?}
  validates_uniqueness_of :sp_type, :scope => [:shop_id], unless: Proc.new{|s| s.sp_link.blank?}
end
