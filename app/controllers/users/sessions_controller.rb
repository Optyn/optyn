class Users::SessionsController < Devise::SessionsController
	before_filter :require_manager_logged_out

	def create
		self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    after_sign_in_path_for(resource)
	end
end