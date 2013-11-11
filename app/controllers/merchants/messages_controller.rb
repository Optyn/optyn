class Merchants::MessagesController < Merchants::BaseController
  
  include Messagecenter::CommonsHelper
  include Messagecenter::CommonFilters
  def types
    #Do Nothing
  end

  def new
    @message = Message.new
    @message.manager_id = current_manager.id
    #@message.build_message_image
  end

  def create
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.new(params[:message].except(:label_ids).merge(manager_id: current_manager.id))
      @message.label_ids = params[:message][:label_ids]
      populate_datetimes

      if @message.send(params[:choice].to_sym)
        message_redirection
      else
        render "new"
      end
    end
  end

  def edit
    @message = Message.for_uuid(params[:id])
    @message_type = @message.type.underscore
    #@message.build_message_image if @message.message_image.blank?
  end

  def update
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.for_uuid(params[:id])
      @message.manager_id = current_manager.id

      @message.attributes = params[:message].except(:label_ids)
      @message.label_ids = params[:message][:label_ids]  || []

      populate_datetimes
      if @message.send(params[:choice].to_sym)
        message_redirection
      else
        render "edit"
      end
    end
  end

  def update_meta
    klass = params[:message_type].classify.constantize
    @message = klass.for_uuid(params[:id])
    @message.subject = params[:message][:subject]
    @message.send_on = params[:message][:send_on]
    @message.save!

    render json: {message: render_to_string(partial: "merchants/messages/preview_meta")}

  rescue => e
    render json: {message: render_to_string(partial: "merchants/messages/meta_form", locals: {message: @message})}, status: :unprocessable_entity
  end

  def create_response_message
     if "na" == params[:id]
       klass = params[:message_type].classify.constantize
       @message = klass.new(params[:message])
       @message.manager_id = current_manager.id
       @message.save_draft
       params[:id] = @message.uuid
     end

     parent_message = create_child_message

     @message = parent_message
     @message_type = @message.type.underscore
    render json: {response_message: render_to_string(partial: 'merchants/messages/edit_fields_wrapper', locals: {parent_message: parent_message})}
  rescue => e
    puts e.message
    puts e.backtrace
    render json: {error_message: 'Could not create the response message. Please save your survey message and try again.'}, status: :unprocessable_entity
  end

  def preview
    @message = Message.for_uuid(params[:id])
    @shop_logo = true
    @shop = @message.shop
  end

  def show
    @message = Message.for_uuid(params[:id])
    @shop = @message.shop
    @shop_logo = true
  end

  def launch
    @message = Message.for_uuid(params[:id])
    @message.launch
    params[:choice] = "launch"
    message_redirection
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
    

    render partial: "merchants/messages/preview_wrapper", locals: {preview: true, customer_name: nil}
  end

  def public_view
    if params["message_name"]
      uuid = params["message_name"].split("-").last
      @message = Message.for_uuid(uuid)
      @shop_logo = true
      @shop = @message.shop
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
      link = "#{SiteConfig.app_base_url}/#{public_view_messages_path(message.shop.name.parameterize, msg.parameterize)}"
      fb_body = message.call_fb_api(link)
      twitter_body = message.call_twitter_api(link)
    end
    render partial: 'merchants/messages/report', locals: {message: message, timestamp_attr: timestamp_attr, fb_body: fb_body, twitter_body: twitter_body}
  end

  def share_email

  end

  def send_shared_email
    message = Message.find(params[:message_id])
    @users = params[:To].split(",")
    @users.each do |user_email|
      ShareMailer.shared_email(user_email.strip, message).deliver
    end
    respond_to do |format|
      format.html { 
        redirect_to(root_path, notice: 'Email was successfully sent.') 
      }
    end
  end

  private
  def populate_user_folder_count(force=false)
    @inbox_count = MessageUser.cached_user_inbox_count(current_user, force)
  end
end
