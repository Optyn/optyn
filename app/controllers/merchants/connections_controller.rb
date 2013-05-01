class Merchants::ConnectionsController < Merchants::BaseController
	skip_before_filter :active_subscription?

  def index
    @connections = Connection.shops_connections(current_shop.id)
  end
end
