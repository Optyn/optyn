class Connection < ActiveRecord::Base
  CONNECTED_VIA_WEBSITE = 'Website'
  CONNECTED_VIA_DASHBOARD = 'Optyn Dashboard'
  CONNECTED_VIA_BUTTON = 'Optyn Button'
  CONNECTED_VIA_EMAIL_BOX = 'Optyn Email Box'
  CONNECTED_VIA_IMPORT = 'Import'
  CONNECTED_VIA_EXTENSION = 'Chrome Extension'
  CONNECTED_VIA_TYPES = [CONNECTED_VIA_BUTTON, CONNECTED_VIA_EMAIL_BOX, CONNECTED_VIA_WEBSITE, CONNECTED_VIA_DASHBOARD, CONNECTED_VIA_IMPORT, CONNECTED_VIA_EXTENSION]

  belongs_to :user
  belongs_to :shop

  attr_accessible :user_id, :shop_id, :active, :connected_via, :disconnect_event

  attr_accessor :skip_payment_email

  after_save :check_shop_tier

  validate :shop_id, presence: true

  validate :user_id, presence: true

  scope :active, where(active: true)

  scope :inactive, where(active: false)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :includes_shop, includes(:shop)

  scope :includes_business_and_locations, includes(shop: [:locations, :businesses])

  scope :ordered_by_shop_name, order("shops.name ASC")

  scope :latest_updates, order("connections.updated_at DESC")

  scope :includes_user_and_permissions, includes(user: {permissions_users: :permission})

  scope :includes_user, includes(:user)

  scope :for_users, ->(user_identifiers) { where(user_id: user_identifiers) }

  scope :time_range, ->(start_timestamp, end_timestamp) { where(created_at: start_timestamp..end_timestamp) }

  scope :for_shop_in_time_range, ->(shop_id, start_timestamp, end_timestamp) { for_shop(shop_id).time_range(start_timestamp, end_timestamp) }

  scope :connection_medium, ->(medium) { where(["connections.connected_via = :medium", {medium: medium}]) }

  scope :connected_via_optyn_button, connection_medium(CONNECTED_VIA_BUTTON)

  scope :connected_via_email_box, connection_medium(CONNECTED_VIA_EMAIL_BOX)

  scope :distinct_receiver_ids, select('DISTINCT(connections.user_id)')

  scope :shop_and_user_present, where("connections.user_id IS NOT NULL AND connections.shop_id IS NOT NULL")

  PER_PAGE = 50
  PAGE = 1

  def self.for_shop_and_user(shop_identifier, user_identifier)
    for_shop(shop_identifier).for_users(user_identifier).shop_and_user_present.first
  end

  def self.paginated_shops_connections(shop_id, page = PAGE, per_page = PER_PAGE)
    active.for_shop(shop_id).shop_and_user_present.includes_user_and_permissions.latest_updates.page(page).per(per_page)
  end

  def self.shop_connections_count_total(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "total")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      active.shop_and_user_present.for_shop(shop_id).count
    end
  end

  def self.shop_connections_count_month(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "month")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      shop_and_user_present.for_shop_in_time_range(shop_id, 30.days.ago.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.shop_connections_count_week(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "week")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      shop_and_user_present.for_shop_in_time_range(shop_id, 7.days.ago.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.shop_connections_count_day(shop_id, force = false)
    cache_key = create_count_cache_key(shop_id, "day")
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      shop_and_user_present.for_shop_in_time_range(shop_id, 24.hours.ago.beginning_of_day, Time.now.end_of_day).count
    end
  end

  def self.shop_latest_connections(shop_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-latest-connections-shop-#{shop_id}"
    Rails.cache.fetch(cache_key, force: force, expires_in: SiteConfig.ttls.dashboard_count) do
      for_shop(shop_id).active.includes_shop.includes_user.shop_and_user_present.limit(limit_count).all
    end
  end

  def self.shop_dashboard_disconnected_connections(shop_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-disconnected-connections-shop-#{shop_id}"
    Rails.cache.fetch(cache_key, force: force, expires_in: SiteConfig.ttls.dashboard_count) do
      for_shop(shop_id).inactive.latest_updates.includes_shop.shop_and_user_present.limit(limit_count).all
    end
  end

  #user dashboard latest connections
  def self.latest_connections(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-latest-connections-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_users(user_id).active.includes_shop.shop_and_user_present.latest_updates.limit(limit_count).all
    end
  end

  #user dashboard dropped connections
  def self.dashboard_disconnected_connections(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-disconnected-connections-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      for_users(user_id).inactive.latest_updates.shop_and_user_present.includes_shop.limit(limit_count).all
    end
  end

  def self.mark_inactive_bounce_or_complaint(message_email_auditor)
    shop = message_email_auditor.shop
    user = message_email_auditor.user

    if user.present? && shop.present?
      connection = Connection.for_shop_and_user(shop.id, user.id)
      connection.make_inactive
    end
  end

  def toggle_connection
    self.toggle!(:active)
  end

  def make_inactive
    self.update_attribute(:active, false)
  end

  def connection_status
    self.active ? "Following" : "Opt in"
  end

  def check_shop_tier
    owner_shop = self.shop
    owner_shop.skip_payment_email = self.skip_payment_email if self.skip_payment_email
    owner_shop.check_subscription
  end


  private
  def self.create_count_cache_key(shop_id, suffix)
    "connection-count-shop-#{shop_id}-time-range-#{suffix}"
  end
end
