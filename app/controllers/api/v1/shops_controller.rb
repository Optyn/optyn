module Api
	module V1
		class ShopsController < BaseController
			before_filter :fetch_store
			
			def details
				#todo to be implemented with
				respond_with @shop.api_welcome_details	
			end

			private
			def fetch_store
				@shop = Shop.by_app_id(params[:app_id].to_s)

				head :unauthorized and false unless @shop.present?
			end
		end
	end
end