module Api
	module V1
		class UsersController < ApiBaseController
			doorkeeper_for :all
			
			before_filter :map_current_user_to_store

			def show
				#respond_with current_user.as_json(only: [:name])
				if params[:callback].present?
					resp = "var userInfo = #{current_user.as_json(only: [:name]).to_json};" 
					resp << "#{params[:callback]}(userInfo);"
					render text: resp
				else
					respond_with current_user.as_json(only: [:name])
				end
			end

			private
		end
	end
end