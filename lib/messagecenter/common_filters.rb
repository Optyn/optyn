module Messagecenter
  module CommonFilters
    def self.included(controller)
      controller.class_eval do
        controller.before_filter(:populate_message_type, :populate_labels, only: [:new, :create, :edit, :update, :create_response_message])
        controller.before_filter(:show_my_messages_only, only: [:show])
        controller.before_filter(:message_editable?, only: [:edit, :update])
        controller.before_filter(:message_showable?, only: [:show])
        controller.before_filter(:populate_manager_folder_count)
        controller.before_filter(:merge_end_date_time, only: [:create, :update])
        controller.before_filter :merge_send_on, only: [:create, :update, :update_meta]
        controller.skip_before_filter :authenticate_user!, only: [:public_view]

        controller.helper_method(:registered_action_location)
      end
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
      @message.beginning = params[:message][:beginning].present? ? Time.parse(params[:message][:beginning]) : nil
      @message.ending = params[:message][:ending].present? ? Time.parse(params[:message][:ending]) : nil
    end

    def show_my_messages_only
      @message = Message.for_uuid(params[:id])
      @message_shop = @message.shop
      if @message_shop != current_shop
        redirect_to(inbox_messages_path)
        return false
      end
      true
    end

    def message_editable?
      @message = Message.for_uuid(params[:id])

      if current_shop != @message.shop || !@message.editable_state?
        redirect_to merchants_message_path(@message.uuid)
      end
    end

    def message_showable?
      @message = Message.for_uuid(params[:id])
      unless @message.showable?
        redirect_to edit_merchants_message_path(params[:id])
      end
    end

    def populate_manager_folder_count
      @drafts_count = Message.cached_drafts_count(current_shop) if current_shop
      @queued_count = Message.cached_queued_count(current_shop) if current_shop
    end

    def registered_action_location
      eval("#{registered_action}_merchants_messages_path(:page => #{@page || session[:page] || 1})")
    end

    def create_child_message
      parent_message = Message.for_uuid(params[:id])
      klass = params[:child_message_type].classify.constantize
      message = klass.new(name: params[:child_message_name])
      message.manager_id = current_manager.id
      message.parent_id = parent_message.id
      message.save_draft
      parent_message
    end

    def merge_end_date_time
      if params[:message][:ending_date].present? || params[:message][:ending_time].present?
        params[:message][:ending] = params[:message][:ending_date].to_s + " " + params[:message][:ending_time].to_s
      end
    end

    def merge_send_on
      if params[:message][:send_on_date].present? || params[:message][:send_on_time].present?
        params[:message][:send_on] = params[:message][:send_on_date].to_s + " " + params[:message][:send_on_time]
      end
    end

  end #end CommonFilter module
end #end of the Messagecenter module