class Merchants::AppsController < Merchants::BaseController
  helper_method :current_shop

  REDIRECTION_URI_FLASH = "You have an incorrect redirection url. Are you possibly missing the protocol http:// or https://?"

  before_filter :set_report_content

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


  def set_report_content #PIVOTAL STORY 51368293
    @optyn_button_stats = true
    @optyn_impressions = get_optyn_impressions
    @opt_ins = get_opt_ins_via_button
    @conversion_percent = @opt_ins/@optyn_impressions * 100  rescue 'NA' #Conversion percent (Opt-ins/Optyn impressions * 100)
  end

  def get_optyn_impressions #Optyn button impressions count
    current_shop.button_impression_count.to_i
  end

  def get_opt_ins_via_button #Opt-ins through the Optyn button
    current_shop.connections.where("connected_via LIKE 'Optyn Button'").count
  end
end