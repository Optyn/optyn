class Connection < ActiveRecord::Base
	belongs_to :user
	belongs_to :shop

	attr_accessible :user_id, :shop_id, :active, :connected_via

  scope :active, where(active: true)

	scope :for_shop, ->(shop_identifier){where(shop_id: shop_identifier)}

  scope :includes_business_and_locations, includes(shop: [:locations, :businesses])

  scope :ordered_by_shop_name, order("shops.name ASC")

  scope :for_users, ->(user_identifiers){where(user_id: user_identifiers)}

  def toggle_connection
  	if self.active
  		self.active = false
  	else
  		self.active = true
  	end	
  	self.save
  end

  def connection_status
  	self.active ? "Following" : "Opt in"
  end
end
