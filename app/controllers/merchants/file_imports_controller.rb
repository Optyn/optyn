class Merchants::FileImportsController < Merchants::BaseController
  def index
    current_merchants_manager.file_imports.build
  end

  def create
    if current_merchants_manager.save
      Resque.enqueue(ImportCsvUser, params[:manager]["file_imports_attributes"]["0"]["csv_file"].tempfile.to_path.to_s, current_shop.id,current_merchants_manager.id)
      redirect_to merchants_dashboard_index_path, notice: "Customers imported."
    else
      redirect_to merchants_dashboard_index_path, notice: "Customers not imported."
    end
  end
end
