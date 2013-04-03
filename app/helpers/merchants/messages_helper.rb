module Merchants::MessagesHelper
  def formatted_message_form_send_on(message)
    if message.send_on.present?
      message.send_on.strftime('%m/%d/%Y %I:%M %p')
    end
  end

  def message_form_title(message_type)
    case message_type
      when Message::DEFAULT_FIELD_TEMPLATE_TYPE
        return "New General Announcement Campaign"
      when Message::COUPON_FIELD_TEMPLATE_TYPE
        return "New Coupon Campaign"
      when Message::EVENT_FIELD_TEMPLATE_TYPE
        return "New Event Announcement Campaign"
      when Message::PRODUCT_FIELD_TEMPLATE_TYPE
        return "New Product Announcement Campaign"
      when Message::SALE_FIELD_TEMPLATE_TYPE
        return "New Sale Announcement Campaign"
      when Message::SPECIAL_FIELD_TEMPLATE_TYPE
        return "New Special Announcement Campaign"
      when Message::SURVEY_FIELD_TEMPLATE_TYPE
        return "New Survey Campaign"
      else
        return "New Campaign"
    end
  end
end
