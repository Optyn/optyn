module ConnectionsHelper
	def user_permission(user)
		if user.permissions_users.present?
			permission_user=user.permissions_users.where(:action=>true)
			if permission_user.size == Permission.all.size
				"Full"
			else
			 user.find_user_permission.join(" ")
			end
		else
			"None"
		end
	end
end


