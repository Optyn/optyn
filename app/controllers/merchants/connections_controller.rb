class Merchants::ConnectionsController < Merchants::BaseController
	skip_before_filter :active_subscription?
  def index
  end
end
