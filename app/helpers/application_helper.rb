require 'shop_logo'

module ApplicationHelper
  include ShopLogo

  def human_date(time)
    time.strftime(HUMAN_DATE_FORMAT)
  end

  def human_time(time)
    time.strftime(HUMAN_TIME_FORMAT)
  end

  def user_present?
    user_signed_in? || merchants_manager_signed_in?
  end

  alias_method :someone_logged_in?, :user_present?

  def has_locations?
    manager = current_merchants_manager
    manager && manager.shop.stype=="local" && !manager.shop.locations.any?
  end

  def is_shop_online?(shop)
    shop.is_online?
  end

  def is_shop_local?(shop)
    shop.is_local?
  end

  def display_title(content = nil)
    @title_called = true
    default_content = "Optyn.com - Improving the Marketing Relationship"
    content_for :title do
      title_content = content.blank? ? default_content : content
      content_tag :title do
        title_content 
      end  
    end
  end

  def display_meta_description(description = nil, keywords = nil)
    @meta_description_called = true
    content_for :meta_description do
      default_description = "Optyn improves the marketing relationship between businesses and their customers. We help businesses easily engage their customers, while giving tools to consumers to help them manage their incoming marketing communications."
      default_keywords = "optyn, opt-in, opt in, email marketing, universal opt-in, universal opt in, customer engagement, engagement marketing, local marketing, local e-mail marketing"
      tag('meta', name: "Description", content: description.blank? ? default_description : description) +
      tag('meta', name: "keywords", content: keywords.blank? ? default_keywords : keywords)
    end
  end

  def display_flash_message
    flash_type = fetch_flash_type
    content_tag :div, class: "alert #{bootstrap_class_for(flash_type)}" do
      content = ""
      content << content_tag(:button, {:type => "button", :class => "close", :'data-dismiss' => "alert"}) do
        "x"
      end
      content << flash[flash_type]
      content.html_safe
    end if flash_type.present?
    
  end

  def fetch_flash_type
    if flash[:notice].present?
      :notice
    elsif flash[:error].present?
      :error
    elsif flash[:alert].present?
      :alert
    elsif flash[:success].present?
      :success
    end
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-error"
      when :notice
        "alert-success"
      else
        'alert'
    end
  end

  def custom_error_messages(errors, options={})
    unless errors.blank?()
      content_tag(:div, :class => "error") do
        content_tag(:strong, (options[:header] || "Please correct the following fields:")).+(
            content_tag(:ol) do
              errors.full_messages().collect() do |error|
                content_tag(:li, error)
              end.join("").html_safe()
            end
        )
      end
    end
  end


  def user_permission(user)
    visible_permissions_users = user.permissions_users.select(&:action)
    if visible_permissions_users.present?

      if visible_permissions_users.size == Permission.cached_count
        "Full"
      else
        user.permission_names.join(", ")
      end
    else
      "None"
    end
  end

  def shop_logo(shop)
    image_name = shop.logo_img? ? shop.logo_img.url : 'no_shop_logo.gif'
    image_tag(image_name, alt: shop.name, class: 'shop-logo')
  end

  def human_paginated_range(collection)
    endnumber = ((collection.offset_value + collection.limit_value) > collection.total_count) ? collection.total_count : (collection.offset_value + collection.limit_value)
    return "" if collection.blank? || collection.total_count <= collection.limit_value
    "Showing #{collection.offset_value + 1}-#{endnumber} of #{collection.total_count}"
  end

  def active_tab_class(hightlight_controllers=[])
     "active" if hightlight_controllers.include?(controller_name)
  end

  def shop_public_page_login_location
    user_signed_in? ? consumers_root_path : merchants_manager_signed_in? ? merchants_root_path : new_user_session_path
  end
  def small_cass(application_call_to_action)
    application_call_to_action == 1 ? "small" : "large"

  end

  def checkbox_image(checkmark_icon)
    checkmark_icon == false ?  "noCheckMark" : ""
  end

  def banner(content="Optyn")
    content_for :banner do
      content_tag(:h1) do 
        content
      end
    end
  end

  def message_partner_name(shop)
    if shop.partner.eatstreet?
      return "eatstreet"
    elsif shop.partner.optyn?
      return "optyn"
    end
  rescue
    "optyn"
  end

  def hide_header_footer
      (['edit', 'preview', 'edit_metadata', 'new'].include? params[ :action ]  and params[ :controller ] == 'merchants/messages') ? false : true
  end
end
