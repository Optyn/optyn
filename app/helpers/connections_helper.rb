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
    shop.stype.titleize rescue "-"
  end

  # def connection_user_display_name(connection, name_id, email_id)
  #   user = connection.user
  #   connection.user.permissions_users.each do |permission_user|
  #     if permission_user.permission_id == name_id  && permission_user.action
  #       if user.full_name.present?
  #         return user.full_name
  #       else
  #         next
  #       end
  #     end

  #     if (permission_user.permission_id == email_id && permission_user.action)
  #       return user.email
  #     else
  #       return "Optyn User #{connection.user.id}"
  #     end
  #   end 
  # end

  # def connection_user_name(permission_user, user, name_id)
  #   # permission_user.permission_id == name_id && permission_user.action ? user.full_name : "-"
  #   user.full_name
  # end

  # def connection_user_email(permission_user, user, email_id)
  #   # permission_user.permission_id == email_id && permission_user.action ? user.email : "-"
  #   user.email
  # end
end


