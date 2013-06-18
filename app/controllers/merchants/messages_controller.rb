class Merchants::MessagesController < Merchants::BaseController
  include Messagecenter::CommonsHelper

  before_filter :populate_message_type, :populate_labels, only: [:new, :create, :edit, :update, :create_response_message]
  before_filter :show_my_messages_only, only: [:show]
  before_filter :message_editable?, only: [:edit, :update]
  before_filter :message_showable?, only: [:show]
  before_filter :populate_manager_folder_count

  helper_method :registered_action_location

  def types
    #Do Nothing
  end

  def new
    @message = Message.new
    @message.manager_id = current_manager.id
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
    @message = Message.find_by_uuid(params[:id])
    @message_type = @message.type.underscore
  end

  def update
    Message.transaction do
      klass = params[:message_type].classify.constantize
      @message = klass.find_by_uuid(params[:id])
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
    @message = klass.find_by_uuid(params[:id])
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
    @message = Message.find_by_uuid(params[:id])
  end

  def show
    @message = Message.find_by_uuid(params[:id])
  end

  def launch
    @message = Message.find_by_uuid(params[:id])
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
    parent_message = Message.find_by_uuid(params[:id]).parent
    parent_message.reload

    render json: {response_email_fields: render_to_string(partial: "merchants/shared/messages/response_email_fields", locals: {parent_message: parent_message})}
  end

  #pivotal story 51368113
  def report 
    @message = Message.find_by_uuid(params[:id])
    @intended_recipients = @message.intended_recipients
    @actual_recipients = @message.actual_recipients
    @opt_outs = @message.opt_outs
  end

  private
  def populate_message_type
    @message_type = Message.fetch_template_name(params[:message_type])
  end

  def populate_labels
    @labels = current_shop.labels
  end

  def message_redirection
    choice = params[:choice]

    if params[:edit_child_location].present?
      redirect_to params[:edit_child_location]
    elsif "save_and_navigate_parent" == choice
      redirect_to edit_merchants_message_path(@message.parent.uuid)
    elsif "preview" == choice
      redirect_to preview_merchants_message_path(@message.uuid)
    elsif "launch" == choice
      redirect_to queued_merchants_messages_path()
    else
      redirect_to edit_merchants_message_path(@message.uuid)
    end
  end

  def populate_datetimes
    @message.beginning = Time.parse(params[:message][:beginning]) if params[:message][:beginning].present?
    @message.ending = Time.parse(params[:message][:ending]) if params[:message][:ending].present?
  end

  def show_my_messages_only
    @message = Message.find_by_uuid(params[:id])
    @message_manager = @message.manager(current_user)
    if @message_manager != current_manager
      redirect_to(inbox_messages_path)
      return false
    end
    true
  end

  def message_editable?
    @message = Message.find_by_uuid(params[:id])

    if !current_manager == @message.manager || !@message.editable_state?
      redirect_to merchants_message_path(@message.uuid)
    end
  end

  def message_showable?
    @message = Message.find_by_uuid(params[:id])
    unless @message.showable?
      redirect_to edit_merchants_message_path(params[:id])
    end
  end

  def populate_manager_folder_count
    @drafts_count = Message.cached_drafts_count(current_manager)
    @queued_count = Message.cached_queued_count(current_manager)
  end

  def registered_action_location
    eval("#{registered_action}_merchants_messages_path(:page => #{@page || 1})")
  end

  def create_child_message
    parent_message = Message.find_by_uuid(params[:id])
    klass = params[:child_message_type].classify.constantize
    message = klass.new(name: params[:child_message_name])
    message.manager_id = current_manager.id
    message.parent_id = parent_message.id
    message.save_draft
    parent_message
  end

end
