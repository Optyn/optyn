class Merchants::ConnectionsController < Merchants::BaseController
	
  def index
    @connections = Connection.paginated_shops_connections(current_shop.id, params[:page])
  end
end
