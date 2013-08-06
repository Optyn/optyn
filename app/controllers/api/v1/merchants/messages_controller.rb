module Api
  module V1
    module Merchants
      class MessagesController < PartnerOwnerBaseController
        include Messagecenter::CommonsHelper
        include Messagecenter::CommonFilters

        before_filter :require_message_type, only: [:new, :create, :edit, :update, :create_response_message]

        def types
          @types = Message::FIELD_TEMPLATE_TYPES
        end

        def create
          Message.transaction do
            klass = params[:message_type].classify.constantize
            @message = klass.new(params[:message])
            @message.manager_id = current_manager.id
            populate_datetimes

            template = "api/v1/merchants/messages/message"
            if @message.send(params[:choice].to_s.to_sym)
              render(status: :created, template: template)
            else
              render(status: :unprocessable_entity, template: template)
            end
          end
        end

        def show
          @message = Message.for_uuid(params[:id])
          template = "api/v1/merchants/messages/message"
          render(status: :created, template: template)
        end

        private
        def require_message_type
          if @message_type.blank?
            @message = Message.new
            @message.errors.add(:base, "Missing the type of message to be created")
            render(status: :unprocessable_entity, template: "api/v1/merchants/messages/errors")
            false
          end
        end
      end #end of the MessagesController class
    end #end of Merchants module
  end #end of the V1 module
end #end of the Api module

