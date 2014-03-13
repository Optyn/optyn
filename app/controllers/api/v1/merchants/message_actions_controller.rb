module Api
  module V1
    module Merchants
      class MessageActionsController < PartnerOwnerBaseController
        rescue_from ActiveModel::MassAssignmentSecurity::Error, with: :handle_assignment_exception
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

        include Messagecenter::CommonsHelper
        include Messagecenter::CommonFilters        

        def validate
          @message = Message.for_uuid(params[:message_uuid])
          @success = (current_manager.present? && @message.present?) ? true :false
          @msg = (current_manager.present? || @message.present?) ? "" : "You dont have permission or the link has expired" 
        end

      end
    end
  end
end

