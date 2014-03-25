module Api
  module V1
    module Merchants
      class MessageActionsController < PartnerOwnerBaseController
        rescue_from ActiveModel::MassAssignmentSecurity::Error, with: :handle_assignment_exception
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
        skip_before_filter :message_showable?

        INCOMING_DATE_FORMAT = "%m-%d-%Y"
        OUTGOING_DATE_FORMAT = "%Y-%m-%d"
        INCOMING_TIME_FORMAT = "%I:%M %p"
        OUTGOING_TIME_FORMAT = "%I:%M %p"

        include Messagecenter::CommonsHelper
        include Messagecenter::CommonFilters        

        def validate
          @message = Message.for_uuid(params[:message_uuid])
          @success = (current_manager.present? && @message.present?) ? true :false
          @msg = (current_manager.present? || @message.present?) ? "" : "The link has expired" 
        end

        def get_message
          @message_change_notifier = MessageChangeNotifier.for_message_id_and_message_change_id(params[:message_uuid], params[:message_change_uuid])
          @message = (@message_change_notifier.message rescue nil)
          @success = @message_change_notifier.present? ? true : false
          @msg =@message_change_notifier.present? ? "" : "The link has expired. A moditfication to the message has been made. Please contact support@optyn.com if you are facing problems."
        end

        def update  	
          Message.transaction do
            
            klass = params[:message_type].classify.constantize
            @message = klass.for_uuid(params[:id])
            @message.manager_id = current_manager.id

            @message.attributes = filter_time_params
            @message.label_ids = [params[:message][:label_ids]] || []
            populate_datetimes
            save_only = params[:message][:choice]== "save" ? true : false
            @needs_curation = @message.needs_curation(:pending_approval)
            set_message_image

            if @message.send(:send_for_approval)
              render(save_only: save_only,status: :ok, template: individual_message_template_location, layout: false, formats: [:json], handlers: [:rabl])
            else
              render(status: :unprocessable_entity, template: individual_message_template_location)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          @message.errors.add(:base, e.message)
          render(status: :unprocessable_entity, template: individual_message_template_location)
        end  

        def reject
          @message_change_notifier = MessageChangeNotifier.find(params[:id])
          @message = @message_change_notifier.message
          @message_change_notifier.attributes = params[:message_change_notifier]
          if @message_change_notifier.save && @message.reject
            MessageRejectionWorker.perform_async(@message_change_notifier.id)
            @success = true
          else
            @error = "#{@message.errors.first.first.to_s.humanize} #{@message.errors.first.last}"
            @success = false
          end
        end

        def approve
          @message = Message.for_uuid(params[:message_uuid])
          launched = @message.send(:launch)
          @message_change_notifier = MessageChangeNotifier.for_uuid(params[:message_change_uuid])
          
          if launched
            @success = true
          else
            @error = "#{@message.errors.first.first.to_s.humanize} #{@message.errors.first.last}"
            @success = false
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

        def merge_end_date_time
          ending_date = params[:message][:ending_date]
          ending_time = params[:message][:ending_time]

          if ending_date.present? || ending_time.present?
            params[:message][:ending] = parsed_datetime_str(ending_date, ending_time)
          end

        end

        def parsed_datetime_str(date_str, time_str)
          parsed_date_str = date_str.present? ? Date.strptime(date_str, INCOMING_DATE_FORMAT).strftime(OUTGOING_DATE_FORMAT) : Date.today.strftime(OUTGOING_DATE_FORMAT) 
          parsed_time_str = time_str.present? ? Time.strptime(time_str, INCOMING_TIME_FORMAT).strftime(OUTGOING_TIME_FORMAT) : Time.now.end_of_day.strftime(OUTGOING_TIME_FORMAT) 
          puts "---- #{parsed_date_str + " " + parsed_time_str}"
          parsed_date_str + " " + parsed_time_str
        end

        def set_message_image
           if params[:message][:message_image_attributes] && params[:message][:message_image_attributes][:image] 
            image_params = params[:message][:message_image_attributes][:image] 
            tempfile = Tempfile.new("fileupload")
            tempfile.binmode
            tempfile.write(Base64.decode64(image_params["file"]))
            @uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => image_params["filename"], :original_filename => image_params["original_filename"]) 
            @uploaded_file.headers=image_params[:headers]
            @uploaded_file.content_type=image_params[:content_type]
            params[:message][:message_image_attributes] = {:image=>@uploaded_file }
            #message_image = @message.build_message_image(params[:message][:message_image_attributes])
            @message.message_image_attributes = params[:message][:message_image_attributes]
          end
        end
      end #end of MessageActionsController
    end #end of Merchants module
  end #end of V1 module
end #end of Api module

