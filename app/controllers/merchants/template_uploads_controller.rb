class Merchants::TemplateUploadsController < Merchants::BaseController
  http_basic_authenticate_with name: "", password: "9p5yn123"

  def new
    @template_upload = TemplateUpload.new
  end

  def create
    @template_upload = TemplateUpload.new(params[:merchants_template_upload])
    @template_upload.manager_id = current_manager.id

    if @template_upload.save
      flash.now[:notice] = "Successfully uploaded the template."
      render action: 'new'
    else
      flash.now[:error] = "Could not upload the template"
    end
  end
end
