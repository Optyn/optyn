class SocialProfile < ActiveRecord::Base
  belongs_to :shop
  attr_accessible :sp_link, :sp_type

  SOCIAL_PROFILES = [["1", "facebook"], ["2", "twitter"], ["3", "linkedin"]]

  validates :sp_link, uniqueness: true, :presence => true
  validates :sp_type, uniqueness: true,	:presence => true

  validates_format_of :sp_link, :with => URI::regexp(%w(http https))
end
