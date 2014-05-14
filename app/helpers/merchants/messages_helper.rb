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
    message.send(message_attr.to_s.to_sym).strftime('%m/%d/%Y %I:%M %p %Z')
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
      when Message::TEMPLATE_FIELD_TEMPLATE_TYPE
        "#{action_name.humanize} Campaign".titleize
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
      when Message::TEMPLATE_FIELD_TEMPLATE_TYPE
        "Template"
      else
        "N/A"
    end
  end

  def message_greeting(message, preview = false, receiver = nil)
    greeting_prefix = case
                        when message.instance_of?(CouponMessage)
                          "Great News"
                        when message.instance_of?(SpecialMessage)
                          "Great News"
                        when message.instance_of?(SaleMessage)
                          "Hi"
                        when message.instance_of?(GeneralMessage)
                          "Hello"
                        when message.instance_of?(ProductMessage)
                          "Hi"
                        when message.instance_of?(EventMessage)
                          "Event News"
                        when message.instance_of?(SurveyMessage)
                          "Your feedback is valuable"
                        else
                          "Hello"
                      end
    if @message_name.blank?
      greeting_suffix = (receiver.first_name rescue "{{Customer Name}}") #message.in_preview_mode?(preview) || ('inbox' != registered_action rescue nil) ? "{{Customer Name}}" : (receiver.first_name )
    else
      greeting_suffix = ""
    end
    "#{greeting_prefix}#{(" " + greeting_suffix) if greeting_suffix.present?},"
  end

  def message_rendering_partial(message)
    message.type.underscore
  end

  def message_discount_type_text(message)
    amount = message.sanitized_discount_amount
    message.percentage_off? ? (amount.to_s + "%") : number_to_currency(amount, precision: (amount.to_s.include?(".") ? 2 : 0)) #pluralize(amount, "$")
  end

  def message_content(message, receiver=nil)
    if message.instance_of?(VirtualMessage)
      return raw(display_content)
    end

    display_content = message.content.blank? ? "-" : message.personalized_content(receiver)
    display_content.match(/<p>.*<\/p>/ixm) ? raw(display_content) : simple_format(display_content)
    display_content = process_urls(display_content, message, receiver)
    display_content.to_s.html_safe
  end

  def process_urls(display_content, message, receiver)
    html = Nokogiri::HTML::fragment(display_content)

    #replace urls in a tags
    html.css('a').each do |link|
      original_href = link['href']
      link['href'] = optyn_tracking_url(message, receiver, original_href)
    end
    return html.to_s
  rescue => e
    Rails.logger.error e
    return display_content
  end

  def optyn_tracking_url(message, receiver, original_href)
    user_info_token = Encryptor.encrypt_for_template({:message_id => message.id, :manager_id => message.manager_id,  :email => (receiver.email rescue '')})
    optyn_url = "#{SiteConfig.email_app_base_url}#{SiteConfig.simple_delivery.link_path}?uit=#{user_info_token}"
    optyn_url = "#{optyn_url}&redirect_url=#{original_href}"
    optyn_url
  end

  def message_receiver_labels(label_names)
    if 1 == label_names.size
      return "All Connections" if Label::SELECT_ALL_NAME == label_names.first
    end

    label_names.join(", ")
  end

  def messages_menu_links(user, path, link_name, count, force_visible=false, highlight_actions=[])
    #if force_visible || user.message_authoring_or_admin_rights?
    link_to(raw("#{link_name}#{" <span>#{count}</span>" if (count.to_i > 0 rescue false)}"), path, :class => message_menu_highlight_class(highlight_actions, link_name))
    #end
  end

  def message_menu_highlight_class(highlight_actions, link_name="", highlight_class="menu-header")
    if highlight_actions.include?(action_name)
      return highlight_class
    end

    return highlight_class if !["new", "edit", "create", "update", "types", "preview", "create_response_message", "launch", "new_template", "template", "edit_template", "preview_template", "system_layouts", "system_layout_properties"].include?(action_name) && registered_action == link_name.to_s.gsub("&nbsp;", "").strip.downcase
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

  def message_bottom_image(message, message_user)
    if message.show_image?
      button_url = message.button_url
      subject = message.personalized_subject(message_user)
      website = message.shop.display_website

      if button_url.present? || website.present?
        href = button_url.present? ? button_url : website
        content = link_to(image_tag(message.message_image.image.to_s, title: subject, style: 'max-width: 100%;').html_safe, href)
        content = process_urls(content, message, message_user)
        content.html_safe
      else
        image_tag(message.message_image.image.to_s, title: subject, style: 'max-width: 100%;')
      end  

    end
  end

  def message_progress_bar_highlight(hightlight_action_names=[])
    "current" if hightlight_action_names.include?(action_name)
  end

  def get_public_link(message, shop)
    msg = "#{message.name} #{message.uuid}"
    return public_view_messages_path(shop.name.parameterize, msg.parameterize)
  end

  def get_social_share_link(type, message, public_msg_url, options = {})
    # message = (message.is_a? Message) ? message.name : message
    case type
    when "facebook"
      query = {
        link: public_msg_url,
        display: "popup",
        caption: message.generic_subject,
        app_id: SiteConfig.facebook_app_key,
        redirect_uri: SiteConfig.app_base_url,
        description: "I would like to share and spread this campaign."
      }.to_query
      return URI.parse("#{FACEBOOK_SHARE_API}?#{query}")
    when "twitter"
      params = options['via'].present? ? "&via=#{options['via']}" : ""
      googl = Shortly::Clients::Googl
      short_url = googl.shorten(public_msg_url).shortUrl
      URI.parse(URI.encode("#{TWITTER_SHARE_API}?text=#{message.generic_subject}&url=#{short_url}#{params}"))
    end
  end


  def get_default_html(type)
    case type
    when "facebook"
      return "<a href=#{get_social_share_link('facebook','', 'http://optyn.com')} style='background: #3a589b;float:left;color: #fff;height: 50px;padding-top:4px;text-decoration:none;width: 50%;' target='_blank' class='ss-fbshare'>
                  <img alt='Icon-facebook' src='http://localhost:3000/assets/icon-facebook.png' style='vertical-align:middle;'>
                </a>                "
    when "twitter"
      return "<a href = #{get_social_share_link('twitter', 'optyn', 'http://optyn.com')} style='background:#598dca;float:left;color: #fff;height: 50px;padding-top:4px;text-decoration:none;width: 50%;' target ='_blank' class = 'ss-twittershare'>
                <img alt='Icon-twitter' src='http://localhost:3000/assets/icon-twitter.png' style='vertical-align:middle;'>
              </a>"
    end
  end

  def optyn_user?(email_of_recepient=nil)
    return false if email_of_recepient.nil?
    
    if email_of_recepient
      if User.find_by_email(email_of_recepient)
        return true
      else
        return false
      end
    end
  end

  def message_header_background_color(message)
    "#{message.header_background_color_css_val rescue Shop::DEFAULT_HEADER_BACKGROUND_COLOR}"
  end

  def message_footer_background_color(message)
    "#{message.footer_background_color_css_val rescue Shop::DEFAULT_FOOTER_BACKGROUND_COLOR};"
  end

  def system_templates_link_caption(template)
    content = <<-HTML
      <div class="template-description">
        <span class="system-template-name"><strong>#{template.name}</strong></span>
        <br />
        <span><small>#{system_template_description(template.name)}</small><span>
      </div>
    HTML

    content.html_safe
  end

  def system_template_description(template_name)
    if "Basic" == template_name
      "Full width - 1 column. A perfect way to strike a conversation with your customer. This template is more content driven."
    elsif "Hero" == template_name
      "Awesome, when you want to converse on multiple thoughts with your customers."
    elsif "Left Sidebar" == template_name
      "Includes a left bar for creating just the correct context for your information."
    elsif "Right Sidebar" == template_name
      "Includes a right bar for creating just the correct context for your information."
    elsif "Galleria" == template_name
      "Excellent way to communicate visually with with your customers."
    else
      ""
    end
  end

  def is_sidebar_template(template_name)
    Message::SIDEBAR_TEMPLATS.include?(template_name) ? true : false
  end
  
  def is_hero_template(template_name)
    Message::HERO_TEMPLAT.include?(template_name) ? true : false
  end

  def next_tab(old_tab, template_name)
    if Message::SIDEBAR_TEMPLATS.include?(template_name)
       "template_sidebar"
     elsif Message::HERO_TEMPLAT.include?(template_name)
      "template_sidebar"
    else
      old_tab
    end
  end

  
end
