module DashboardCleaner
  def flush_message_latest_messages_and_counts
    yield
    if @flush
      #flush the cache
      MessageUser.coupon_messages_count(current_user.id, true) if @message.instance_of?(CouponMessage)
      MessageUser.special_messages_count(current_user.id, true) if @message.instance_of?(SpecialMessage)
      MessageUser.new_messages_count(current_user.id, true)
      MessageUser.latest_messages(current_user.id, SiteConfig.dashboard_limit, true)
    end
  end

  def flush_new_connections
    yield
    if @flush
      Connection.latest_connections(current_user.id, true)
    end
  end

  def flush_disconnected_connections
    yield
    if @flush
      Connection.dashboard_disconnected_connections(current_user.id, true)
    end
  end
end