class Location < ActiveRecord::Base
  attr_accessible :city, :shop_id, :state, :street_address1, :street_address2,:longitude,:latitude

  belongs_to :shop

  validates :city,:presence=>true
  validates :shop_id,:presence=>true
  validates :state,:presence=>true
  validates :longitude,:presence=>true
  validates :latitude,:presence=>true

end
