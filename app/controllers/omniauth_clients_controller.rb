class OmniauthClientsController < ApplicationController
	def create
		raise env['omniauth.auth'].to_yaml
	end
end
