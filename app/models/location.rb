class Location < ActiveRecord::Base
  
  attr_accessible :city,:zip, :shop_id, :state, :street_address1, :street_address2,:longitude,:latitude

  belongs_to :shop

  validates :city, :presence=>true
  validates :street_address1, :presence=>true
  validates :zip, :presence=>true
  validates :zip,:length=>{:minimum=> 5,:maximum=>5,:message=>"code is invalid"},:if => lambda{|location| location.zip.length!=0}
  validates_format_of :zip, :with => /^\d+$/,:if => lambda{|location| location.zip.length!=0}
  validates :state, :presence=>true
  #validates :longitude, :presence=>true
  #validates :latitude, :presence=>true

end
