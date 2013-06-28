class Merchants::ConnectionsController < Merchants::BaseController
	
  def index
    @connections = Connection.shops_connections(current_shop.id)
  end
end
