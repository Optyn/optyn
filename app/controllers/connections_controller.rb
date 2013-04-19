
class ConnectionsController < BaseController
	def index
		@connections = current_user.active_connections(params[:page])
	end

	def make
		@shops = Shop.disconnected(current_user.active_shop_ids) 
	end

	def add_connection
		@shop = Shop.find(params[:shop_id])
		begin
			if @shop.present?
				if current_user.shop_ids.include?(@shop.id)
					@connection = current_user.connections.where(:shop_id=>@shop.id).first
					if @connection.toggle_connection
						followed=@connection.active
						render :json =>{:success=>true,:success_text=>@connection.connection_status,:hover_text=>"Unfollow",:followed=>followed}
					else
						render :json =>{:success=>false,:success_text=>@connection.connection_status,:error_message=>"Connection failed"}
					end	
				else
					@connection = current_user.connections.new(:shop_id=>@shop.id)
					if @connection.save
						followed=@connection.active
						render :json =>{:success=>true,:success_text=>"Following",:followed=>followed}
					else
						render :json =>{:success=>false,:success_text=>"Opt In",:error_message=>"Connection failed"}
					end	
				end
			end			
		rescue		
			render :json =>{:success=>false,:error_message=>"Oops, Something went wrong."}
		end	
	end
end
