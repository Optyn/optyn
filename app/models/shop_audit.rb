class ShopAudit < ActiveRecord::Base

	belongs_to :Shop

   attr_accessible :shop_id, :description
end
