class Location < ActiveRecord::Base
  include UuidFinder

  attr_accessor :state_abbr
  attr_accessible :city, :zip, :shop_id, :state_id, :street_address1, :street_address2, :longitude, :latitude, :state_abbr


  belongs_to :shop
  belongs_to :state

  before_validation :assign_uuid, on: :create

  validates :city, :presence => true
  validates :street_address1, :presence => true
  validates :zip, :presence => true
  validates :zip, :length => {:minimum => 5, :maximum => 5, :message => "is invalid"}, :if => lambda { |location| location.zip.length!=0 }
  validates_format_of :zip, :with => /^\d+$/, :if => lambda { |location| location.zip.length!=0 }
  validates :state_id, :presence => true
  #validates :longitude, :presence=>true
  #validates :latitude, :presence=>true

  def state_name
    state.name
  end

  def state_abbr
    self.state.abbreviation rescue nil
  end

  def error_messages
    self.errors.full_messages
  end

  private
  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end
end
