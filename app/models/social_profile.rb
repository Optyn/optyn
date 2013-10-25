class SocialProfile < ActiveRecord::Base
  belongs_to :shop
  attr_accessible :sp_link, :sp_type

  SOCIAL_PROFILES = [["1", "facebook"], ["2", "twitter"], ["3", "linkedin"]]

  validates :sp_link, :presence => true
  validates :sp_type, :presence => true
end
