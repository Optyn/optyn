class Merchants::ConnectionsController < Merchants::BaseController
	skip_before_filter :active_subscription?
  def index
  	@connected_user = current_shop.users
  	respond_to do |format|
  		format.html
  		format.csv {render text: Connection.to_csv(@connected_user)}
  	end
  end
end
