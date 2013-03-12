class Users::SessionsController < Devise::SessionsController
	before_filter :require_manager_logged_out
end