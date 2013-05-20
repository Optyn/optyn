class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  attr_accessible :user_id, :shop_id, :active, :connected_via

  scope :active, where(active: true)

  scope :inactive, where(active: false)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :includes_shop, includes(:shop)

  scope :includes_business_and_locations, includes(shop: [:locations, :businesses])

  scope :ordered_by_shop_name, order("shops.name ASC")

  scope :latest_updates, order("connections.updated_at DESC")

  scope :includes_user_and_permissions, includes(user: {permissions_users: :permission})

  scope :for_users, ->(user_identifiers) { where(user_id: user_identifiers) }

  scope :time_range, ->(start_timestamp, end_timestamp) { where(created_at: start_timestamp..end_timestamp) }

  scope :for_shop_in_time_range, ->(shop_id, start_timestamp, end_timestamp) { for_shop(shop_id).time_range(start_timestamp, end_timestamp) }

  def self.shops_connections(shop_id)
    for_shop(shop_id).includes_user_and_permissions
  end

  def self.shop_connections_count_total(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "total")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_shop(shop_id).count
    end
  end

  def self.shop_connections_count_month(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "month")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_shop_in_time_range(shop_id, Time.now.beginning_of_month.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.shop_connections_count_week(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "week")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_shop_in_time_range(shop_id, Time.now.beginning_of_week.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.shop_connections_count_day(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "day")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_shop_in_time_range(shop_id, Date.yesterday.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.latest_connections(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-latest-connections-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_users(user_id).active.includes_shop.limit(limit_count).all
    end
  end

  def self.dashboard_disconnected_connections(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-disconnected-connections-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_users(user_id).inactive.latest_updates.includes_shop.limit(limit_count).all
    end
  end

  def toggle_connection
    if self.active
      self.active = false
    else
      self.active = true
    end
    self.save
  end

  def connection_status
    self.active ? "Following" : "Opt in"
  end

  private
  def self.create_count_cache_key(shop_id, suffix)
    "connection-count-shop-#{shop_id}-time-range-#{suffix}"
  end
end
