module Messagecenter
  module CommonsHelper
    def self.included(controller)
      controller.helper_method :registered_action, :get_pagination_data ##implemented as a filter in commons filter
      controller.helper_method(:registered_action_location) #implemented as a filter in commons filter
    end


    def uuids_from_message_ids
      return params[:message_ids] if params[:message_ids].is_a?(Array)

      params[:message_ids].split(",")
    end
  end
end