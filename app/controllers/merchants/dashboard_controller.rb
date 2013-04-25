class Merchants::DashboardController < Merchants::BaseController
	skip_before_filter :active_subscription?
  def index
  end

  def import
  	User.import(params[:file], current_shop)
  	redirect_to merchants_dashboard_index_path, notice: "Customers imported."
	end
end
