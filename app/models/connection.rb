class Connection < ActiveRecord::Base
	belongs_to :user
	belongs_to :shop

	attr_accessible :user_id, :shop_id, :active

  scope :active, where(active: true)

	scope :for_shop, ->(shop_identifier){where(shop_id: shop_identifier)}
end
