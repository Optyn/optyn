module ConnectionsHelper
	def get_connection_status(shop,user)
		connection = shop.get_connection_for_user(user).first
		if connection.present?
			connection.connection_status 
		else
			"Opt in"
		end
	end

	def connections_tab_class(highlight_action_name)
		highlight_action_name == action_name ? "active" : ""
	end

  def business_type(shop)
    shop.stype.titleize
  end
end


