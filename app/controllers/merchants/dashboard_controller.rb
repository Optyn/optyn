class Merchants::DashboardController < Merchants::BaseController
	skip_before_filter :active_subscription?
  def index
  end

  def import
  	Resque.enqueue(ImportUser, params["file"].tempfile.to_path.to_s, current_shop.id)
  	redirect_to merchants_dashboard_index_path, notice: "Customers imported."
	end
end
