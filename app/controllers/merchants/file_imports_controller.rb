class Merchants::FileImportsController < Merchants::BaseController

  def new
    current_merchants_manager.file_imports.build
  end

  def index
    current_merchants_manager.file_imports.build
  end

  def create
    @file_import = FileImport.new(params[:file_import])
    @file_import.manager_id = current_manager.id

    if @file_import.save
      Resque.enqueue(UserImporter, @file_import.id)
      redirect_to merchants_dashboard_index_path, notice: "Your CSV file has been queued for import. We will send you an email with the statistics once the import is complete."
    else
      render 'index'
    end
  end
end
