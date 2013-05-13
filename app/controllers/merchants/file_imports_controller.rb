class Merchants::FileImportsController < Merchants::BaseController

  def index
    @file_imports = current_manager.file_imports
    @file_import = FileImport.new
  end

  def create
    @file_import = FileImport.new(params[:file_import])
    @file_import.manager_id = current_manager.id

    if @file_import.save
      Resque.enqueue(UserImporter, @file_import.id)
      redirect_to merchants_file_imports_path, notice: "Your CSV file has been queued for import. We will send you an email with the statistics once the import is complete."
    else
      render 'index'
    end
  end
end
