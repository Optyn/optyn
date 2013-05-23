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
      Connection.latest_connections(current_user.id, SiteConfig.dashboard_limit, true)
    end
  end

  def flush_disconnected_connections
    yield
    if @flush
      Connection.dashboard_disconnected_connections(current_user.id, SiteConfig.dashboard_limit, true)
    end
  end

  def flush_recommended_connections
    yield
    if @flush
      User.recommend_connections(current_user.id, SiteConfig.dashboard_limit, true)
    end
  end

  def flush_dashboard_unanswered_surveys
    yield
    if @flush
      current_user.dashboard_unanswered_surveys(SiteConfig.dashboard_limit, true)
    end
  end
end