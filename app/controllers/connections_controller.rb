class ConnectionsController < BaseController
	def index
	end
	def show
		#@shop = Shop.find(params[:id])
	end

	def add_connection
		@shop = Shop.find(params[:shop_id])
		begin
			if @shop.present?
				if current_user.shop_ids.include?(@shop.id)
					connection = current_user.connections.where(:shop_id=>@shop.id).first
					if connection.toggle_connection

						render :json =>{:success=>true,:success_text=>connection.connection_status,:hover_text=>"Unfollow"}
					else
						render :json =>{:success=>false,:success_text=>connection.connection_status,:error_message=>"Connection failed"}
					end	
				else
					connection = current_user.connections.new(:shop_id=>@shop.id)
					if connection.save
						render :json =>{:success=>true,:success_text=>"Following"}
					else
						render :json =>{:success=>false,:success_text=>"Opt In",:error_message=>"Connection failed"}
					end	
				end
			end			
		rescue		
			render :json =>{:success=>false,:error_message=>"Something went wrong"}
		end	
	end
end
