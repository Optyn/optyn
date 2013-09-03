module Api
  module V1
  	class ApiController < ::ApplicationController
	    def current_resource_owner
	      doorkeeper_token.application.owner if doorkeeper_token
	    end
  	end
  end
end