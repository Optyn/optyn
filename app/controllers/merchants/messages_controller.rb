class Merchants::MessagesController < Merchants::BaseController

  include Messagecenter::CommonsHelper
  include Messagecenter::CommonFilters

  before_filter :populate_shop_surveys, only: [:new, :create, :edit, :update, :create_response_message]

  skip_before_filter :authenticate_merchants_manager!, :set_time_zone, :check_connection_count, only: [:reject, :save]
  before_filter :check_validity_before_rejection, only: [:reject]

  LAUNCH_FLASH_ERROR = "Could not queue the message for sending."

  def types
    #Do Nothing
  end

  ##show just before calling sending of survey link
  ##so that user can select survey
  def select_survey
    @list_survey = Survey.where(:shop_id=>current_shop.id)
  end

  def new
    survey_id = params[:survey_id]
    @message = Message.new
    @message.manager_id = current_manager.id
    @shop = current_shop
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

  def create
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.new(params[:message].except(:label_ids, :send_on_date, :send_on_time).merge(manager_id: current_manager.id))
      populate_send_on if @message.instance_of?(TemplateMessage)
      @message.label_ids = params[:message][:label_ids]
      populate_datetimes

      message_method_call = check_subscription
      if @message.send(message_method_call.to_sym)
        message_redirection
      else
        flash.now[:error] = LAUNCH_FLASH_ERROR
        render "new"
      end
    end
  end

  def template
    @system_templates = Template.system_generated
    @templates = current_shop.templates
    @message = Message.for_uuid(params[:id])
  end

  def edit
    @message = Message.for_uuid(params[:id])
    populate_shop_surveys
    @message_type = @message.type.underscore
  end

  def update
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.for_uuid(params[:id])
      @message.manager_id = current_manager.id

      populate_send_on if @message.instance_of?(TemplateMessage)
      @message.attributes = params[:message].except(:label_ids)
      @message.label_ids = params[:message][:label_ids]  || []

      populate_datetimes
      message_method_call = check_subscription
      if @message.send(message_method_call.to_sym)
        message_redirection
      else
        flash.now[:error] = LAUNCH_FLASH_ERROR
        render "edit"
      end
    end
  end

  def assign_template
    @message = Message.for_uuid(params[:id])
    @message.assign_template(params[:template_id])
    render partial: 'editor_wrapper', layout: false
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
      render action: 'edit'
    else
      flash.now[:error] = LAUNCH_FLASH_ERROR
      render action: 'edit'
    end

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


    render partial: "merchants/messages/preview_wrapper", locals: {preview: true, customer_name: nil}
  end

  def public_view
    @user = current_user if current_user.present?
    if params["message_name"]
      uuid = params["message_name"].split("-").last
      @message = Message.for_uuid(uuid)
      @shop_logo = true
      @shop = @message.shop
      @partner = @shop.partner
      @inbox_count = populate_user_folder_count(true) if current_user.present?

      if @shop and @message
        if @message.make_public
          if not current_user.present?
            respond_to do |format|
              format.html {render :layout => false}
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

  def generate_qr_code
    @message = Message.find(params[:message_id])
    link = @message.get_qr_code_link(current_user)
    respond_to do |format|
      format.html
      format.svg  { render :qrcode => link, :level => :l, :unit => 10 }
      format.png  { render :qrcode => link }
      format.gif  { render :qrcode => link }
      format.jpeg { render :qrcode => link }
    end
  end

  def redeem
    message_user = Encryptor.decrypt(params[:message_user]).split("--")
    message_id = message_user[0] if message_user[0]
    user_id = message_user[1] if message_user[1]
    @message = Message.find(message_id)
    rc = RedeemCoupon.new(:message_id => message_id)
    rc.user_id = user_id if user_id
    if not rc.save
      @error_message = "Sorry, your coupon could not be redeemed."
    end
  end

  def report
    message = Message.find(params[:id])
    timestamp_attr = 'updated_at'
    fb_body = nil
    if message.make_public
      msg = "#{message.name} #{message.uuid}"
      link = "#{SiteConfig.app_base_url}#{public_view_messages_path(message.shop.name.parameterize, msg.parameterize)}"
      fb_body = message.call_fb_api(link)
      twitter_body = message.call_twitter_api(link)
    end
    render partial: 'merchants/messages/social_report', locals: {message: message, timestamp_attr: timestamp_attr, fb_body: fb_body, twitter_body: twitter_body}
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

  def reject
    if request.get?
      render(layout: 'email_feedback')
    elsif request.put?
      @message_change_notifier = MessageChangeNotifier.find(@message_change_notifier.id)
      @message_change_notifier.attributes = params[:message_change_notifier]
      @message_change_notifier.save
      @message.reject
      MessageRejectionWorker.perform_async(@message_change_notifier.id)
      render(layout: 'email_feedback')
    end
  end

  def custom_template
    @template_upload = TemplateUpload.new
  end

  def upload_template
    @template_upload = TemplateUpload.new
    @template_upload.manager_id = current_manager.id
    @template_upload.template_html_file = params[:template_upload][:template_html_file].read
    if @template_upload.save
      @template_upload.save_content
      @system_templates = Template.system_generated
      @templates = current_shop.templates
      @message = Message.for_uuid(params[:id])
      render :template
    else
      @errors = @template_upload.errors.full_messages
      render :custom_template
    end
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

  def check_validity_before_rejection
    message_uuid, message_change_uuid = fetch_message_and_change_identifiers
    @message_change_notifier = MessageChangeNotifier.for_message_id_and_message_change_id(message_uuid, message_change_uuid)
    @message = (@message_change_notifier.message rescue nil)

    unless @message_change_notifier.present?
      flash[:notice] = "The link has expired. A moditfication to the message has been made. Please contact support@optyn.com if you are facing problems."
      redirect_to root_path
      false
    end
  end

  def fetch_message_and_change_identifiers
    plain_text = Encryptor.decrypt(params[:id])
    plain_text.split("--")
  end
end
