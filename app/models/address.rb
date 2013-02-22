class Address < ActiveRecord::Base
  attr_accessible :city, :merchant_id, :state, :street_address1, :street_address2,:longitude,:latitude
  belongs_to :merchant
end
