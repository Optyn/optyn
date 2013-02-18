class OmniauthClientsController < ApplicationController
	def create
		raise env['omniauth.auth'].to_yaml
	end

	def failure
		redirect_to new_user_session_path, :flash => { :error => "Operation Cancelled" }
	end
end
