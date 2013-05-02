class Merchants::AppsController < Merchants::BaseController
  helper_method :current_shop

  REDIRECTION_URI_FLASH = "You have an incorrect redirection url. Are you possibly missing the protocol http:// or https://?"

  def create
    current_shop.generate_oauth_token(params[:oauth_application])
    @application = current_shop.oauth_application

    render json: {preview_content: render_to_string(partial: "merchants/apps/preview"),
                  form_content: render_to_string(partial: 'merchants/apps/edit'),
                  advanced_content: render_to_string(partial: 'merchants/apps/advanced')
    }
  rescue
    render json: {error_message: REDIRECTION_URI_FLASH}, status: :unprocessable_entity
  end

  def show
    @application = current_shop.oauth_application.blank? ? current_shop.build_oauth_application : current_shop.oauth_application
  end

  def update
    current_shop.generate_oauth_token(params[:oauth_application], "true" == params[:reset])
    @application = current_shop.oauth_application
    render json: {preview_content: render_to_string(partial: "merchants/apps/preview"),
                  form_content: render_to_string(partial: 'merchants/apps/edit'),
                  advanced_content: render_to_string(partial: 'merchants/apps/advanced')
                 }
  rescue
    render json: {error_message: REDIRECTION_URI_FLASH}, status: :unprocessable_entity
  end

  private
  def redirect_to_edit
    if current_shop.oauth_application.present?
      redirect_to edit_merchants_app_path
    end
  end

  def redirect_to_new
    unless current_shop.oauth_application.present?
      redirect_to new_merchants_app_path
    end
  end
end