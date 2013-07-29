module Merchants::MessagesHelper
  def message_send_on_date(message)
     message.send_on = 1.hour.since if message.send_on.blank?
     formatted_message_form_datetime(message, 'send_on')
  end

  def formatted_message_form_date(message, message_attr)
    message.send(message_attr.to_s.to_sym).strftime('%Y-%m-%d')
  rescue
    ""
  end

  def formatted_message_form_time(message, message_attr)
    message.send(message_attr.to_s.to_sym).strftime('%I:%M %p')
  rescue
    ""
  end

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

  def message_type_title(message)
    case message.type.underscore
      when Message::DEFAULT_FIELD_TEMPLATE_TYPE
        "General Announcement"
      when Message::COUPON_FIELD_TEMPLATE_TYPE
        "Coupon"
      when Message::EVENT_FIELD_TEMPLATE_TYPE
        "Event Announcement"
      when Message::PRODUCT_FIELD_TEMPLATE_TYPE
        "Product Announcement"
      when Message::SALE_FIELD_TEMPLATE_TYPE
        "Sale Announcement"
      when Message::SPECIAL_FIELD_TEMPLATE_TYPE
        "Special Announcement"
      when Message::SURVEY_FIELD_TEMPLATE_TYPE
        "Survey"
      else
        "N/A"
    end
  end

  def message_greeting(message, preview = false, customer_name = nil)
    greeting_prefix = case
                        when message.instance_of?(CouponMessage)
                          "Great News"
                        when message.instance_of?(SpecialMessage)
                          "Special News"
                        when message.instance_of?(SaleMessage)
                          "Sale News"
                        when message.instance_of?(GeneralMessage)
                          "Hello"
                        when message.instance_of?(ProductMessage)
                          "Product News"
                        when message.instance_of?(EventMessage)
                          "Event News"
                        when message.instance_of?(SurveyMessage)
                          "Your feedback is valuable"
                        else
                          "Hello"
                      end

    greeting_suffix = message.in_preview_mode?(preview) || ('inbox' != registered_action rescue nil) ? "{{Customer Name}}" : customer_name

    "#{greeting_prefix} #{greeting_suffix},"
  end

  def message_rendering_partial(message)
    message.type.underscore
  end

  def message_discount_type_text(message)
    amount = message.sanitized_discount_amount
    message.percentage_off? ? (amount.to_s + " percent") : pluralize(amount, "dollar")
  end

  def message_content(message)
    display_content = message.content.blank? ? "-" : message.content
    if message.instance_of?(VirtualMessage)
      return display_content.html_safe
    end

    simple_format(display_content)
  end

  def message_receiver_labels(label_names)
    if 1 == label_names.size
      return "All Connections" if Label::SELECT_ALL_NAME == label_names.first
    end

    label_names.join(", ")
  end

  def messages_menu_links(user, path, link_name, count, force_visible=false, highlight_actions=[])
    #if force_visible || user.message_authoring_or_admin_rights?
    link_to("#{link_name}#{" (#{count})" if (count.to_i > 0 rescue false)}", path, :class => message_menu_highlight_class(highlight_actions, link_name))
    #end
  end

  def message_menu_highlight_class(highlight_actions, link_name="", highlight_class="menu-header")
    if highlight_actions.include?(action_name)
      return highlight_class
    end

    return highlight_class if !["new", "edit", "create", "update", "types", "preview", "create_response_message"].include?(action_name) && registered_action == link_name.to_s.gsub("&nbsp;", "").strip.downcase
  end

  def message_detail_date(message)
    send_on = message.send_on
    time_format = '%b %d'

    unless send_on.try(:year) == Time.now.year
      time_format << ", %Y"
    end

    send_on.strftime(time_format)
  rescue
    ""
  end

  def message_queued_disabled(message)
    message.queued_editable? ? {} : {disabled: 'disabled'}
  end

  def mark_message_unread_if(message)
    message.unread ? 'message-unread' : ''
  end
end
