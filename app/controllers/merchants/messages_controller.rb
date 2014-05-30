require 'rubygems'
require 'rqrcode'
require 'rqrcode/export/png'

class Merchants::MessagesController < Merchants::BaseController

  include Messagecenter::CommonsHelper
  include Messagecenter::CommonFilters

  before_filter :populate_shop_surveys, only: [:new, :create, :edit, :update, :create_response_message]

  skip_before_filter :authenticate_merchants_manager!, :set_time_zone, :check_connection_count, only: [:reject, :save, :approve]

  LAUNCH_FLASH_ERROR = "Could not queue the message for sending due to error(s)"

  NON_TEMPLATE_BUTTON_STYLE = "text-decoration:none;color: white;background: #64aaef;-webkit-border-radius: 0;-moz-border-radius: 0;border-radius: 0;font: normal 16px/25px 'Open Sans', sans-serif;letter-spacing: 1px;border-bottom: solid 2px rgba(0, 0, 0, 0.2);-webkit-transition: all 0.2s ease-out;-moz-transition: all 0.2s ease-out;-o-transition: all 0.2s ease-out;transition: all 0.2s ease-out;border-top: 0;border-left: 0;border-right: 0;padding: 3px 10px;display: inline-block;margin-top: 15px;"
  NON_TEMPLATE_CKEDITOR_BUTTON_STYLE = 'border-radius: 0;background: #D4D4D4; padding: 2px 10px;text-decoration: none;display: inline-block;'

  def types
    #Do Nothing
  end

  ##show just before calling sending of survey link
  ##so that user can select survey
  def select_survey
    @list_survey = Survey.where(:shop_id => current_shop.id)
  end

  def new
    survey_id = params[:survey_id]
    @message = Message.new
    @message.manager_id = current_manager.id
    @shop = current_shop
  end

  def default_settable_properties_preview
    @message = Message.for_uuid(params[:id])
    @template = Template.for_uuid(params[:template_id])
    @html = Template.with_default_settable_properties(@template.id, current_shop)

    render action: 'settable_properties_preview', layout: false
  end

  def settable_properties_preview
    @message = Message.for_uuid(params[:id])
    @template = Template.for_uuid(params[:template_id])
    @html = Template.update_settable_properties(@template.id, current_shop, {properties: params[:properties]})

    render layout: false
  end 

  def new_template
    @message_type = "template_message"
    @message = Message.new
    @message.manager_id = current_manager.id
    @shop = current_shop
  end

  def edit_template
    @message = Message.for_uuid(params[:id])
    @message_type = @message.type.underscore
    @shop = current_shop
  end

  def system_layouts
    @message = Message.for_uuid(params[:id])
    @system_layouts = Template.system_generated
  end

  def system_layout_properties
    @message = Message.for_uuid(params[:id])
    @template = Template.for_uuid(params[:template_id])
    @properties = @template.default_selectable_properties(current_shop)
    @header_font_families = Template::HEADER_FONT_FAMILIES
    @msg = "#{@message.name} #{@message.uuid}"
    @public_msg = "#{SiteConfig.email_app_base_url}/#{current_shop.name.parameterize}/campaigns/#{@msg.parameterize}"
  end

  def create
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.new(params[:message].except(:label_ids).merge(manager_id: current_manager.id))
      populate_send_on if @message.instance_of?(TemplateMessage)
      @message.label_ids = params[:message][:label_ids]
      populate_datetimes

      message_method_call = check_subscription

      # update_button_styles

      if @message.send(message_method_call.to_sym)
        redirect_to edit_merchants_message_path(@message.uuid)
      else
        flash.now[:error] = LAUNCH_FLASH_ERROR
        create_failure_action
      end
    end
  end

  def template
    @templates = current_shop.templates
    @message = Message.for_uuid(params[:id])
  end

  def copy
    @message = Message.for_uuid(params[:id])
    @new_message = @message.copy_message
    if @new_message.errors.any? && @new_message.new_record?
      flash[:error] = "Could not copy message."
      redirect_to :back
    else
      flash[:notice] = "Message copied successfully."
      if @message.type == "TemplateMessage"
        redirect_to template_merchants_message_path(@new_message.uuid)
      else
        redirect_to edit_merchants_message_path(@new_message.uuid)
      end
    end
  end

  def show_template
    @templates = current_shop.templates
    @message = Message.for_uuid(params[:id])
  end

  def edit
    @message = Message.for_uuid(params[:id])
    populate_shop_surveys
    update_button_for_ckeditor
    @message_type = @message.type.underscore
    @shop_logo = true
    @shop = @message.shop
    @preview = true
    @partner = current_partner
    @skip_menu = true
    @message_type = @message.type.underscore
  end

  def update
    Message.transaction do
      @choice = params[:choice]
      klass = params[:message_type].classify.constantize
      @message = klass.for_uuid(params[:id])
      @message.manager_id = current_manager.id

      populate_send_on if @message.instance_of?(TemplateMessage)
      @message.attributes = params[:message].except(:label_ids)
      @message.label_ids = params[:message][:label_ids]  || []

      populate_datetimes
      message_method_call = check_subscription
      @shop_logo = true
      @shop = @message.shop
      @preview = true
      @partner = current_partner
      @message_type = @message.type.underscore
      update_button_styles
      if @message.send(message_method_call.to_sym)
           respond_to do |format|
            format.html {redirect_to edit_merchants_message_path(@message.uuid)}
            format.js {}
          end
      else
        flash.now[:error] = LAUNCH_FLASH_ERROR
        respond_to do |format|
          format.html {redirect_to edit_merchants_message_path(@message.uuid)}
          format.js {}
        end
      end
    end
  end

  def assign_template
    @message = Message.for_uuid(params[:id])
    @message.assign_template(params[:template_id], params[:name], {properties: params[:properties]})

    if request.xhr?
      render partial: 'editor_wrapper', layout: false
    else
      redirect_to template_merchants_message_path()
    end
  end

  def editor
    @message = Message.for_uuid(params[:id])
    @template = @message.template
    render layout: false
  end

  def save
    @message = Message.for_uuid(params[:id])
    @message.save_template_content!(params[:message])
    render json: {message: "Successfully Saved"}
  rescue ActiveRecord::RecordInvalid => e
    render json: {message: "Error while saving the content"}, status: :unprocessable_entity
  end

  def update_meta
    klass = params[:message_type].classify.constantize
    @message = klass.for_uuid(params[:id])
    @message.subject = params[:message][:subject]
    populate_send_on

    @message.update_meta!

    render json: {message: render_to_string(partial: "merchants/messages/preview_meta")}

  rescue => e
    render json: {message: render_to_string(partial: "merchants/messages/meta_form", locals: {message: @message})}, status: :unprocessable_entity
  end

  def create_response_message
    if "na" == params[:id]
      klass = params[:message_type].classify.constantize
      @message = klass.new()

      @message.manager_id = current_manager.id
      @message.attributes = params[:message]
      @message.save_draft
      params[:id] = @message.uuid
    end

    parent_message = create_child_message
    @surveys = current_shop.surveys
    @message = parent_message
    @message_type = @message.type.underscore
    populate_manager_folder_count
    render json: {response_message: render_to_string(partial: 'merchants/messages/edit_fields_wrapper', locals: {parent_message: parent_message}),
      message_menu: render_to_string(partial: "merchants/messages/message_menu")
    }
  rescue => e
    puts e.message
    puts e.backtrace
    @surveys = current_shop.surveys
    render json: {error_message: 'Could not create the response message. Please save your survey message and try again.'}, status: :unprocessable_entity
  end

  def preview
    @message = Message.for_uuid(params[:id])
    @shop_logo = true
    @shop = @message.shop
    @preview = true
    @partner = current_partner
    @skip_menu = true
    @message_type = @message.type.underscore
  end

  def preview_template
    @message = Message.for_uuid(params[:id])
  end

  def preview_template_content
    @message = Message.for_uuid(params[:id])
    @template = @message.template
    render layout: false
  end

  def show
    @message = Message.for_uuid(params[:id])
    @shop = @message.shop
    @shop_logo = true
    @preview = true
    @partner = @shop.partner
  end

  def launch
    @message = Message.for_uuid(params[:id])
    params[:choice] = "launch"

    message_method_call = check_subscription

    launched = @message.send(message_method_call.to_sym)

    @message_type = @message.type.underscore
    populate_labels
    if launched && 'launch' == message_method_call
      message_redirection
    elsif launched && 'save_draft' == message_method_call
      if @message.instance_of?(TemplateMessage)
        render action: 'edit_template'
      else
        render action: 'edit'
      end
    else
      flash.now[:error] = LAUNCH_FLASH_ERROR
      if @message.instance_of?(TemplateMessage)
        render action: 'edit_template'
      else
        render action: 'edit'
      end
    end

  end

  def email_self
    @message = Message.for_uuid(params[:id])
    @message.email_self
    head :ok
  end

  def trash
    @messages = Message.paginated_trash(current_shop, params[:page])
  end

  def drafts
    @messages = Message.paginated_drafts(current_shop, params[:page])
  end

  def sent
    @messages = Message.paginated_sent(current_shop, params[:page])
  end

  def queued
    @messages = Message.paginated_queued(current_shop, params[:page])
  end

  def move_to_trash
    Message.move_to_trash(uuids_from_message_ids)
    redirect_to drafts_merchants_messages_path
  end

  def move_to_draft
    Message.move_to_draft(uuids_from_message_ids)
    redirect_to drafts_merchants_messages_path
  end

  def discard
    Message.discard(uuids_from_message_ids)
    redirect_to drafts_merchants_messages_path
  end

  def discard_response_message
    Message.discard([params[:id]])
    parent_message = Message.for_uuid(params[:id]).parent
    parent_message.reload

    render json: {response_email_fields: render_to_string(partial: "merchants/shared/messages/response_email_fields", locals: {parent_message: parent_message})}
  end

  def update_header
    @message = Message.find_by_uuid(params[:id])
    @message.update_visuals(params[:message])
    @shop_logo = true
    @shop = @message.shop
    @partner = @shop.partner


    render partial: "merchants/messages/preview_wrapper", locals: {preview: true, customer: nil}
  end

  def public_view
    @user = current_user if current_user.present?
    if params["message_name"]
      @message_name = params["message_name"]
      uuid = params["message_name"].split("-").last
      @message = Message.for_uuid(uuid)
      @shop_logo = true
      @shop = @message.shop
      @partner = @shop.partner
      @inbox_count = populate_user_folder_count(true) if current_user.present?

      if @shop and @message
        if @message.make_public
          if not current_user.present?
            if @message.type.to_s.underscore == Message::SURVEY_FIELD_TEMPLATE_TYPE
              flash[:notice] = "Sorry, This survey is not for public view."
                redirect_to new_user_session_path 
            else
              respond_to do |format|
                format.html {render :layout => false}
              end
            end
          end
        else
          if current_user.present? #to check if the user is logged in or not
            recipient = @message.message_user(current_user)
            if not recipient
              render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
            end
          else
            redirect_to new_user_session_path
          end
        end
      end
    end
  end

  def report
    @message = Message.for_uuid(params[:id])
  end

  def validate
    @manager = Manager.where(uuid: params[:manager_uuid]).first
    @message = Message.for_uuid(params[:message_uuid])
    success = (@manager.present? && @message.present?) ? true :false
    message = (@manager.present? || @message.present?) ? "" : "You dont have permission or the link has expired" 
    render json: {success: success, message: message}
  end

  def social_report
    message = Message.for_uuid(params[:id])
    timestamp_attr = 'updated_at'
    fb_body = nil
    if message.make_public
      msg = "#{message.name} #{message.uuid}"
      link = "#{SiteConfig.email_app_base_url}#{public_view_messages_path(message.shop.name.parameterize, msg.parameterize)}"
      fb_body = message.call_fb_api(link)
      twitter_body = message.call_twitter_api(link)
    end
    render partial: 'merchants/messages/social_report', locals: {message: message, timestamp_attr: timestamp_attr, fb_body: fb_body, twitter_body: twitter_body}
  end

  def click_report
    message = Message.find(params[:id])
    report_data = EmailTracking.get_message_click_report(message.id)
    render partial: 'merchants/messages/email_tracking_data', locals: {message: message, report_data: report_data}
  end

  def email_report
    message = Message.find_by_uuid(params["id"])
    open_email_user = message.send(params[:report_type])
    populate_report_title
    @emails = render_to_string(partial: 'merchants/messages/email_list', locals: {message: message, report_data: open_email_user})
    render(json: {emails: @emails, report_title: @report_title})
  end

  def share_email

  end

  def send_shared_email
    message = Message.for_uuid(params[:message_id])
    @users = params[:To].split(",")
    @users.each do |user_email|
      message_email_auditor = MessageEmailAuditor.new
      message_email_auditor.message_id = message.id
      message_email_auditor.delivered = false
      message_email_auditor.email_to = user_email.strip
      message_email_auditor.save
      SharedForwarder.perform_async(user_email.strip, message.id, message_email_auditor.id)
    end
    respond_to do |format|
      format.html {
        redirect_to(root_path, notice: 'Email was successfully sent.')
      }
    end
  end

  def remove_message_image
    @message = Message.for_uuid(params[:id])
    message_image = @message.message_image
    message_image.remove_image! if message_image
    @message.message_image.destroy
    message_redirection
  end

  def template_upload_image
    @message = Message.for_uuid(params[:id])
    @message_image = MessageImage.new(:image => params[:files].first, :message_id =>@message.id)
    @message_image.save

    
    render(json: {data: {image_location: @message_image.image_location}})
  end

  def upload_template_image
    if params[:files].present?
      @template_image = TemplateImage.new(:image => params[:files].first)
      @template_image.save
      return render(json: {data: {image_location: @template_image.image_location, image_id: @template_image.id, image_name: @template_image['image']}})
    end
    head :unprocessable_entity 
  end

  def destroy_template
    @template = Template.for_uuid(params[:id])
    @template.destroy
    head :ok
  end

  def edit_metadata
    @skip_menu = true
    @message = Message.for_uuid(params[:id])
    populate_shop_surveys
    populate_labels
    update_button_for_ckeditor
    @shop_logo = true
    @shop = @message.shop
    @preview = true
    @partner = current_partner
    @skip_menu = true
    @message_type = @message.type.underscore
  end

  private
  def check_subscription
    message_method_call = params[:choice]
    if current_shop.disabled? && 'launch' == params[:choice].to_s
      flash[:error] = "Please update your #{ActionController::Base.helpers.link_to 'subscription', merchants_upgrade_subscription_path} before launching a message. We have saved your message in drafts.".html_safe
      message_method_call = 'save_draft'
    end
    message_method_call
  end

  def populate_user_folder_count(force=false)
    @inbox_count = MessageUser.cached_user_inbox_count(current_user, force)
  end

  def choice_launch?
    "launch" == params[:choice]
  end

  def populate_shop_surveys
    underscored_message_type = SurveyMessage.to_s.underscore
    @surveys = current_shop.surveys.active if (@message_type == underscored_message_type || @message.type.underscore == underscored_message_type rescue false)
  end

  def fetch_message_and_change_identifiers
    plain_text = Encryptor.decrypt(params[:id])
    plain_text.split("--")
  end

  def create_failure_action
    return render(action: 'new_template') if @message.instance_of?(TemplateMessage)

    render action: 'new'
  end

  def update_failure_action
    return render(action: 'edit_template') if @message.instance_of?(TemplateMessage)

    render action: 'edit'
  end

  def populate_report_title
    @report_title = case params[:report_type]
    when "open_emails"
      "Emails Opened"
    when "unsubscribes_emails"
      "Emails Unsubscribed"
    when "bounced_emails" 
      "Emails Bounced" 
    when "complaint_emails"  
      "Emails Marked Spam"
    else
      "Email Report"
    end
  end

end
