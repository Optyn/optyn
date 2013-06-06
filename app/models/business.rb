class Business < ActiveRecord::Base
  attr_accessible :name
  belongs_to :shop
  belongs_to :user
end
