class Merchants::MessagesController < Merchants::BaseController
  include Merchants::MessageCounter

  before_filter :populate_message_type, :populate_labels, only: [:new, :create, :edit, :update]
  before_filter :register_close_message_action, only: [:queued, :drafts, :sent, :trash]

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
      @message.label_ids = params[:message][:label_ids]

      populate_datetimes
      if @message.send(params[:choice].to_sym)
        message_redirection
      else
        render "edit"
      end
    end
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

  private
  def populate_message_type
    @message_type = Message.fetch_template_name(params[:message_type])
  end

  def populate_labels
    @labels = current_shop.labels
  end

  def message_redirection
    choice = params[:choice]
    if "preview" == choice
      redirect_to preview_merchants_message_path(@message.uuid)
    elsif "launch" == choice
      #TODO TO BE IMPLEMENTED TO BE REDIRECTED TO THE SENT PAGE.
    else
      redirect_to edit_merchants_message_path(@message.uuid)
    end
  end

  def populate_datetimes
    @message.beginning = Time.parse(params[:message][:beginning]) if params[:message][:beginning].present?
    @message.ending = Time.parse(params[:message][:ending]) if params[:message][:ending].present?
  end

  def uuids_from_message_ids
    params[:message_ids].split(",")
  end

  def register_close_message_action
    session[:registered_action] = action_name
  end

  def registered_action
    session[:registered_action] || "inbox"
  end

  def registered_action_location
    eval("#{registered_action}_messages_path(:page => #{@page || 1})")
  end
end
