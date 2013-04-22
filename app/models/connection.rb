class Connection < ActiveRecord::Base
	belongs_to :user
	belongs_to :shop

	attr_accessible :user_id, :shop_id, :active, :connected_via

  scope :active, where(active: true)

	scope :for_shop, ->(shop_identifier){where(shop_id: shop_identifier)}

  scope :includes_business_and_locations, includes(shop: [:locations, :businesses])

  scope :ordered_by_shop_name, order("shops.name ASC")

  def self.to_csv(connected_user,shop)
    CSV.open("#{Rails.root.to_s}/tmp/records_#{shop.id}.csv", "wb") do |csv|
      csv << ['Name','Email', 'Gender']
      connected_user.each do |user|
        csv << [user.name, user.email, user.gender]
      end
    end  
  end

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
