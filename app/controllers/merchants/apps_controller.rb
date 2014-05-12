class Merchants::AppsController < Merchants::BaseController
  helper_method :current_shop

  REDIRECTION_URI_FLASH = "Please make sure that your url includes http:// or https://. For example, it should be http://www.my-website.com."

  before_filter :set_report_content

  def create
    params[:oauth_application][:label_ids] = params[:oauth_application][:label_ids].reject! { |l| l.empty? }.join(",")
    current_shop.generate_oauth_token(params[:oauth_application])
    @application = current_shop.oauth_application
    @label_ids = @application.label_ids.present? ? @application.label_ids.split(",") : []
    render json: {preview_content: render_to_string(partial: "merchants/apps/preview"),
                  form_content: render_to_string(partial: 'merchants/apps/edit'),
                  advanced_content: render_to_string(partial: 'merchants/apps/advanced')
    }
  rescue
    render json: {error_message: REDIRECTION_URI_FLASH}, status: :unprocessable_entity
  end

  def show
    @application = current_shop.oauth_application.blank? ? current_shop.build_oauth_application : current_shop.oauth_application
    @labels = current_shop.labels.active
    @label_ids = @application.label_ids.present? ? @application.label_ids.split(",") : []

  end

  def update
    params[:oauth_application][:label_ids] = params[:oauth_application][:label_ids].reject! { |l| l.empty? }.join(",")
    current_shop.generate_oauth_token(params[:oauth_application], "true" == params[:reset])
    @application = current_shop.oauth_application
    @label_ids = @application.label_ids.present? ? @application.label_ids.split(",") : []
    render json: {preview_content: render_to_string(partial: "merchants/apps/preview"),
                  form_content: render_to_string(partial: 'merchants/apps/edit'),
                  advanced_content: render_to_string(partial: 'merchants/apps/advanced')
    }
  rescue => e
    render json: {error_message: REDIRECTION_URI_FLASH}, status: :unprocessable_entity
  end


  def fetch_code
    render layout: false
  end


  def set_report_content #PIVOTAL STORY 51368293
    @optyn_button_stats = true
    #optyn button stats
    @optyn_impressions = current_shop.button_impression_count.to_i
    @optyn_button_clicks = current_shop.button_click_count.to_i
    @opt_ins = current_shop.opt_ins_via_button
    @conversion_percent = @opt_ins.to_f / @optyn_impressions.to_f * 100  rescue 'NA' #Conversion percent (Opt-ins/Optyn impressions * 100)
    #optyn email box stats
    @email_box_impressions = current_shop.email_box_impression_count.to_i
    @email_box_clicks = current_shop.email_box_click_count.to_i
    @email_box_opt_ins = current_shop.opt_ins_via_email_box
    @email_box_conversion_percent = current_shop.email_box_conversion_percent
    @labels = current_shop.labels.active
  end

end