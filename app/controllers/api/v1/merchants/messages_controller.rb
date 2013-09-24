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
        before_filter :individual_message_template_location
        before_filter :message_list_template_location

        def types
          @types = Message::FIELD_TEMPLATE_TYPES
        end

        def create
          Message.transaction do
            klass = params[:message_type].classify.constantize
            
            @message = klass.new(filter_time_params)
            @message.manager_id = current_manager.id
            populate_datetimes

            if @message.send(params[:choice].to_s.to_sym)
              render(status: :created, template: individual_message_template_location)
            else
              render(status: :unprocessable_entity, template: individual_message_template_location)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: individual_message_template_location)
        end

        def show
          @message = Message.for_uuid(params[:id])
          render(status: :created, template: individual_message_template_location)
        end

        def update
          Message.transaction do
            klass = params[:message_type].classify.constantize
            @message = klass.for_uuid(params[:id])
            @message.manager_id = current_manager.id

            @message.attributes = filter_time_params
            @message.label_ids = params[:message][:label_ids]  || []

            populate_datetimes
            
            if @message.send(params[:choice].to_s.to_sym)
              render(status: :ok, template: individual_message_template_location)
            else
              render(status: :unprocessable_entity, template: individual_message_template_location)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: individual_message_template_location)
        end

        def show
          @message = Message.for_uuid(params[:id])
          @shop = @message.shop
          render(template: individual_message_template_location)
        end

        def launch
          @message = Message.for_uuid(params[:id])
          @message.launch
          render(template: individual_message_template_location)
        end

        def trash

          @messages = Message.paginated_trash(current_shop, params[:page])

          render(template: message_list_template_location)
        end

        def drafts
          @messages = Message.paginated_drafts(current_shop, params[:page])
          render(template: message_list_template_location)
        end

        def sent
          @messages = Message.paginated_sent(current_shop, params[:page])
          render(template: message_list_template_location)
        end

        def queued
          @messages = Message.paginated_queued(current_shop, params[:page])
          render(template: message_list_template_location)
        end

        def move_to_trash
          Message.move_to_trash(uuids_from_message_ids)
          drafts  
        end

        def move_to_draft
          Message.move_to_draft(uuids_from_message_ids)
          drafts
        end

        def discard
         Message.discard(uuids_from_message_ids)
         drafts
        end

        def preview
          #this function renders a preview
          #input uuid of email
          #output html encassed in json
          binding.pry
          @message = Message.for_uuid(params[:id])
          #@rendered_string = render_to_string(:template => "shared/messages/_core_content")  
          @rendered_string =  @rendered_string = render_to_string(:template => 'api/v1/merchants/messages/preview_email', :layout => false, :formats=>[:html],:handlers=>[:haml])
        end

        private
        def require_message_type
          if @message_type.blank?
            @message = Message.new
            @message.errors.add(:base, "Missing the type of message to be created")
            render(status: :unprocessable_entity, template: individual_message_template_location)
            false
          end
        end

        def handle_assignment_exception
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "You were assigning attributes that are not allowed.")
          render(template: individual_message_template_location, status: :unprocessable_entity)
          
          true
        end

        def handle_record_not_found
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "Sorry, Record you are looking are not found.")
          render(template: individual_message_template_location, status: :unprocessable_entity)

          true
        end

        def populate_message_type
          @message_type = params[:message_type].classify.constantize
        rescue
          @message = Message.new
          @message.manager_id = current_manager.id
          @message.errors.add(:base, "'message_type' in the request missing")
          render(template: individual_message_template_location, status: :unprocessable_entity)

          true
        end

        def filter_time_params
          params[:message].except(:label_ids, :ending_date, :ending_time, :send_on_date, :send_on_time)
        end

        def individual_message_template_location
          "api/v1/merchants/messages/message"
        end

        def message_list_template_location
          "api/v1/merchants/messages/list"
        end

      end #end of the MessagesController class
    end #end of Merchants module
  end #end of the V1 module
end #end of the Api module

