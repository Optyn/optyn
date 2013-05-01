class Merchants::DashboardController < Merchants::BaseController
	skip_before_filter :active_subscription?
  def index
  	current_merchants_manager.import_users.build
  end

  def import
  	if current_merchants_manager.save
  		Resque.enqueue(ImportCsvUser, params[:manager]["import_users_attributes"]["0"]["csv_file"].tempfile.to_path.to_s, current_shop.id,current_merchants_manager.id)
  		redirect_to merchants_dashboard_index_path, notice: "Customers imported."
  	else
			redirect_to merchants_dashboard_index_path, notice: "Customers not imported."  	
  	end
	end
end
