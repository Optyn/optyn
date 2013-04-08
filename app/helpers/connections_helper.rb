module ConnectionsHelper
	def user_permission(user)
		if user.permission.present?
		  if user.permission.vis_name? && user.permission.vis_email?
		   "Full"
		  elsif user.permission.vis_name?
		    "Name"
		  elsif user.permission.vis_email?
		    "Email"
		  else
		   "None"
		 end
		end
	end

	def display_permission(user)
		if user.permission.present?
			if user.permission.vis_name? && user.permission.vis_email?
				"Name - #{user.name} & Email -  #{user.email}"
			elsif user.permission.vis_name?
			  "Name -  #{user.name }"
			else 
				"Email - #{user.email}"
			end
		end
	end
end