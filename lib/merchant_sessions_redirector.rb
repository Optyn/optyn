module MerchantSessionsRedirector
	def after_sign_in_path_for(resource)
		 merchants_connections_path
	end
end