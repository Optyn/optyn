module ConnectionsHelper
	def get_connection_status(shop,user)
		connection = shop.get_connection_for_user(user).first
		if connection.present?
			connection.connection_status 
		else
			"Opt in"
		end
	end
end


