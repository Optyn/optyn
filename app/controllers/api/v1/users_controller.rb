module Api
	module V1
		class UsersController < BaseController
			doorkeeper_for :all
			
			before_filter :map_current_user_to_store

			def show
				respond_with current_user.as_json(only: [:name])
			end

			private
			def map_current_user_to_store
				@shop = doorkeeper_token.application.owner

				current_user.make_connection_if!(@shop)
			end
		end
	end
end