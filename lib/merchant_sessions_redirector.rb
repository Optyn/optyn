module MerchantSessionsRedirector
	def after_sign_in_path_for(resource)
		redirect_to merchants_connections_path
	end
end