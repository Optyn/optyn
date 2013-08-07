module Api
  module V1
    module Merchants
      class MessagesController < PartnerOwnerBaseController
        rescue_from ActiveModel::MassAssignmentSecurity::Error, with: :handle_assignment_exception
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

        include Messagecenter::CommonsHelper
        include Messagecenter::CommonFilters

        skip_before_filter :message_showable?
        
        before_filter :require_message_type, only: [:new, :create, :edit, :update, :create_response_message]

        def types
          @types = Message::FIELD_TEMPLATE_TYPES
        end

        def create
          @template = "api/v1/merchants/messages/message"
          Message.transaction do
            klass = params[:message_type].classify.constantize
            @message = klass.new(filter_time_params)
            @message.manager_id = current_manager.id
            populate_datetimes

            if @message.send(params[:choice].to_s.to_sym)
              render(status: :created, template: @template)
            else
              render(status: :unprocessable_entity, template: @template)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: @template)
        end

        def show
          @message = Message.for_uuid(params[:id])
          template = "api/v1/merchants/messages/message"
          render(status: :created, template: template)
        end

        def update
          @template = "api/v1/merchants/messages/message"
          Message.transaction do
            klass = params[:message_type].classify.constantize
            @message = klass.for_uuid(params[:id])
            @message.manager_id = current_manager.id

            @message.attributes = filter_time_params
            @message.label_ids = params[:message][:label_ids]  || []

            populate_datetimes
            
            if @message.send(params[:choice].to_s.to_sym)
              render(status: :created, template: @template)
            else
              render(status: :unprocessable_entity, template: @template)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: @template)
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

        def handle_assignment_exception
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "You were assigning attributes that are not allowed.")
          render(template: "api/v1/merchants/messages/message", status: :unprocessable_entity)
          
          true
        end

        def handle_record_not_found
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "Sorry, Record you are looking are not found.")
          render(template: "api/v1/merchants/messages/message", status: :unprocessable_entity)

          true
        end

        def populate_message_type
          @message_type = params[:message_type].classify.constantize
        rescue
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "'message_type' in the request missing")
          render(template: "api/v1/merchants/messages/message", status: :unprocessable_entity)

          true
        end

        def filter_time_params
          params[:message].except(:label_ids, :ending_date, :ending_time, :send_on_date, :send_on_time)
        end

      end #end of the MessagesController class
    end #end of Merchants module
  end #end of the V1 module
end #end of the Api module

