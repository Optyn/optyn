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
      @message = klass.new(params[:message])
      @message.manager_id = current_manager.id
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
    message_redirection
  end

  def trash
    @messages = Message.paginated_trash(current_manager, params[:page])
  end

  def drafts
    @messages = Message.paginated_drafts(current_manager, params[:page])
  end

  def sent
    @messages = Message.paginated_sent(current_manager, params[:page])
  end

  def queued
    @messages = Message.paginated_queued(current_manager, params[:page])
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
end
