module Messagecenter
  module CommonsHelper
    def self.included(controller)
      controller.before_filter(:register_close_message_action, :get_pagination_data, only: [:queued, :drafts, :sent, :trash, :inbox, :saved])
      controller.helper_method :registered_action, :get_pagination_data
    end

    def get_pagination_data
      @page = [1, params[:page].to_i].max
      @per_page = session[:per_page]
    end

    def register_close_message_action
      session[:registered_action] = action_name
    end

    def registered_action
      session[:registered_action] || "inbox"
    end

    def uuids_from_message_ids
      return params[:message_ids] if params[:message_ids].is_a?(Array)

      params[:message_ids].split(",")
    end
  end
end