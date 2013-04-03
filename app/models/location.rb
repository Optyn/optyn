class Location < ActiveRecord::Base
  
  attr_accessible :city,:zip, :shop_id, :state_id, :street_address1, :street_address2,:longitude,:latitude
  #geocoded_by :address
  #after_validation :geocode

  belongs_to :shop
  belongs_to :state

  validates :city, :presence=>true
  validates :street_address1, :presence=>true
  validates :zip, :presence=>true
  validates :zip,:length=>{:minimum=> 5,:maximum=>5,:message=>"code is invalid"},:if => lambda{|location| location.zip.length!=0}
  validates_format_of :zip, :with => /^\d+$/,:if => lambda{|location| location.zip.length!=0}
  validates :state_id, :presence => true
  #validates :longitude, :presence=>true
  #validates :latitude, :presence=>true

  def state_name
    state.name
  end

  #def address
    #[street_address1, city, state_name].compact.join(', ')
  #end
end
