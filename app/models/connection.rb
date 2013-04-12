class Connection < ActiveRecord::Base
	belongs_to :user
	belongs_to :shop

	attr_accessible :user_id, :shop_id, :active

  scope :active, where(active: true)

	scope :for_shop, ->(shop_identifier){where(shop_id: shop_identifier)}

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
