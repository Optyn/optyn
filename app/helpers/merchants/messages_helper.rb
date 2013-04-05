module Merchants::MessagesHelper
  def formatted_message_form_datetime(message, message_attr)
    message.send(message_attr.to_s.to_sym).strftime('%Y-%m-%d %I:%M %p')
  rescue
    ""
  end

  def message_form_title(message_type)
    case message_type
      when Message::DEFAULT_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} General Announcement Campaign"
      when Message::COUPON_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Coupon Campaign"
      when Message::EVENT_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Event Announcement Campaign"
      when Message::PRODUCT_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Product Announcement Campaign"
      when Message::SALE_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Sale Announcement Campaign"
      when Message::SPECIAL_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Special Announcement Campaign"
      when Message::SURVEY_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Survey Campaign"
      else
        "#{action_name.humanize} Campaign"
    end
  end

  def message_receiver_labels(label_names)
    if 1 == label_names.size
      return "All Connections" if Label::SELECT_ALL_NAME == label_names.first
    end

    label_names.join(", ")
  end
end
