module ApplicationHelper

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

  def active_tab_class(highlight_action_name)
    highlight_action_name == action_name ? "active" : ""
  end

  def shop_public_page_login_location
    user_signed_in? ? consumer_dashboard_path : merchants_manager_signed_in? ? merchants_dashboards_path : new_user_session_path
  end
end
