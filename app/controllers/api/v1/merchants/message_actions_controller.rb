module Api
  module V1
    module Merchants
      class MessageActionsController < PartnerOwnerBaseController
        rescue_from ActiveModel::MassAssignmentSecurity::Error, with: :handle_assignment_exception
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
        skip_before_filter :message_showable?

        include Messagecenter::CommonsHelper
        include Messagecenter::CommonFilters        

        def validate
          @message = Message.for_uuid(params[:message_uuid])
          @success = (current_manager.present? && @message.present?) ? true :false
          @msg = (current_manager.present? || @message.present?) ? "" : "You dont have permission or the link has expired" 
        end

        def update        	
          Message.transaction do
            klass = params[:message_type].classify.constantize
            @message = klass.for_uuid(params[:id])
            @message.manager_id = current_manager.id

            @message.attributes = filter_time_params
            @message.label_ids = [params[:message][:label_ids]] || []
            populate_datetimes

            @needs_curation = @message.needs_curation(params[:choice])
            set_message_image
            if @message.send(:preview)
              send_for_curation(params[:access_token])
              render(status: :ok, template: individual_message_template_location, layout: false, formats: [:json], handlers: [:rabl])
            else
              render(status: :unprocessable_entity, template: individual_message_template_location)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: individual_message_template_location)
        end        

        def reject
          if request.get?
            render(layout: 'email_feedback')
          elsif request.put?
            @message_change_notifier = MessageChangeNotifier.find(@message_change_notifier.id)
            @message_change_notifier.attributes = params[:message_change_notifier]
            @message_change_notifier.save
            @message.reject
            MessageRejectionWorker.perform_async(@message_change_notifier.id)
            render(layout: 'email_feedback')
          end
        end

        def approve
          if request.get?
            render(layout: 'email_feedback')
          elsif request.put?
            @message_change_notifier = MessageChangeNotifier.find(@message_change_notifier.id)
            @message_change_notifier.attributes = params[:message_change_notifier]
            @message_change_notifier.save
            @message.approve
            render(layout: 'email_feedback')
          end
        end

        private
        
        def filter_time_params
          params[:message].except(:label_ids, :ending_date, :ending_time, :send_on_date, :send_on_time)
        end

        def individual_message_template_location
          "api/v1/merchants/messages/message"
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
      end #end of MessageActionsController
    end #end of Merchants module
  end #end of V1 module
end #end of Api module

