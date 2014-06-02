module Messagecenter
  module CommonsHelper
    def self.included(controller)
      controller.before_filter(:register_close_message_action, :get_pagination_data, only: [:queued, :drafts, :sent, :trash, :inbox, :saved])
      controller.helper_method :registered_action, :get_pagination_data
    end

    def get_pagination_data
      @page = session[:page] = [1, params[:page].to_i].max
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

    def state_from_choice(choice)
      return :queued if "queued" == choice
    end

    def update_button_styles
      unless @message.instance_of?(TemplateMessage)
        if @message.content.match(/<p>.*<\/p>/ixm)
          content_node = Nokogiri::HTML::fragment(@message.content)
          links = content_node.css('a.ss-button-link')
          links.each do |link|
            link['style'] = Merchants::MessagesController::NON_TEMPLATE_BUTTON_STYLE
          end

          @message.content = content_node.to_s
        end
      end
    end

    def update_button_for_ckeditor
      unless @message.instance_of?(TemplateMessage)
        if @message.content.present? && @message.content.match(/<p>.*<\/p>/ixm)
          content_node = Nokogiri::HTML::fragment(@message.content)
          links = content_node.css('a.ss-button-link')
          links.each do |link|
            link['style'] = Merchants::MessagesController::NON_TEMPLATE_CKEDITOR_BUTTON_STYLE
          end

          @message.content = content_node.to_s
        end
      end
    end
  end
end