module ApplicationHelper

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
    if (flash_type = fetch_falsh_type)
      content_tag :div, class: "alert #{bootstrap_class_for(flash_type)}" do
        content = ""
        content << content_tag(:button, {:type => "button", :class => "close", :'data-dismiss' => "alert"}) do
          "x"
        end
        content << flash[flash_type]
        content.html_safe
      end
    end
  end

  def fetch_falsh_type
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

  def user_permission(user)
    if user.visible_permissions_users.present?
      permissions_users = user.visible_permissions_users
      if permissions_users.size == Permission.all.size
        "Full"
      else
        user.permission_names.join(", ")
      end
    else
      "None"
    end
  end

  def human_paginated_range(collection)
    endnumber = ((collection.offset_value + collection.limit_value) > collection.total_count) ? collection.total_count : (collection.offset_value + collection.limit_value)
    return "" if collection.blank? || collection.total_count <= collection.limit_value
    "Showing #{collection.offset_value + 1}-#{endnumber} of #{collection.total_count}"
  end

  def active_tab_class(highlight_action_name)
    highlight_action_name == action_name ? "active" : ""
  end
end
