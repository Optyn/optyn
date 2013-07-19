require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :authentications, :as => :account, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :shops, through: :connections
  has_many :interests, dependent: :destroy, as: :holder
  has_many :businesses, :through => :interests
  has_many :user_labels, dependent: :destroy
  has_many :permissions_users, dependent: :destroy
  has_many :permissions, :through => :permissions_users

  mount_uploader :picture, ImageUploader

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true
  validate :check_for_used_manager_email

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation,
                  :remember_me, :office_zip_code, :home_zip_code, :gender, :birth_date, :business_ids, :permissions_users_attributes, :picture

  attr_accessor :show_password, :skip_password, :show_shop, :shop_identifier

  accepts_nested_attributes_for :permissions_users

  #accepts_nested_attributes_for :permission
  after_create :create_permission_users, :create_alias, :send_welcome_email

  PER_PAGE = 30

  def self.from_omniauth(auth)
    authentication = Authentication.fetch_authentication(auth.provider, auth.uid, "User")
    authentication.image_url = auth.info.image
    authentication.save!
    user = authentication.account
    [user, authentication]
  rescue
    create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    user = nil
    authentication = nil

    User.transaction do
      email = auth.info.email.to_s
      user = User.find_by_email(email) || User.new(name: auth.info.name, email: email)

      provider = auth.provider
      uid = auth.uid

      persist_with_twitter_exception(user, provider)

      authentication = Authentication.fetch_authentication(provider, uid, "User")

      if authentication.blank?
        authentication = user.authentications.new(uid: auth['uid'], provider: auth['provider'], image_url: auth.info.image)
        authentication.save
      end
    end

    [user, authentication]
  end

  def self.recommend_connections(user_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-recommended-connections-user-#{user_id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      user = User.find(user_id)
      zips = [user.home_zip_code, user.office_zip_code].compact

      connection_shop_ids = user.connections.collect(&:shop_id) #Add both connections that are active and inactive
      connection_shop_ids = [0] if connection_shop_ids.blank?

      recommend_shops = []
      recommend_shops << Shop.for_zips(zips, connection_shop_ids).limit(limit_count) if zips.present? && connection_shop_ids.present?

      business_ids = user.interests.collect(&:business_id)
      recommend_shops << Shop.for_businesses(business_ids, connection_shop_ids).limit(limit_count) if business_ids.present? && connection_shop_ids.present?
      recommend_shops.flatten.uniq
    end
  end

  def active_connections(page_number=1, per_page=PER_PAGE)
    connections.active.includes_business_and_locations.ordered_by_shop_name.page(page_number).per(per_page)
  end

  def inactive_connections(page_number=1, per_page=PER_PAGE)
    connections.inactive.includes_business_and_locations.ordered_by_shop_name.page(page_number).per(per_page)
  end

  def disconnected_connections
    Shop.disconnected_connections(self.shop_ids)
  end

  def active_shop_ids
    connections.active.collect(&:shop_id)
  end

  def password_required?
    return false if skip_password.present? && skip_password

    super && authentications.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def create_permission_users
    Permission.all.each do |permission|
      PermissionsUser.create(user_id: self.id, permission_id: permission.id, action: true)
    end
  end

  def create_alias
    optyn_alias = "optyn#{Devise.friendly_token.first(8).downcase}@optynmail.com"
    while User.find_by_alias(optyn_alias).present?
      optyn_alias = "optyn#{Devise.friendly_token.first(8).downcase}@optynmail.com"
    end

    self.alias = optyn_alias
    self.save
  end

  def make_connection_if!(shop)
    if shop.present?
      if !connections.for_shop(shop.id).present?
        connected_via = shop.button_display? ? Connection::CONNECTED_VIA_BUTTON : Connection::CONNECTED_VIA_EMAIL_BOX
        connections.create!(user_id: self.id, shop_id: shop.id, connected_via: connected_via)
      end
      connections.for_shop(shop.id).first
    end
  end

  def dashboard_unanswered_surveys(limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-unanswered-surveys-user-#{self.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      shop_ids = fetch_uanswered_survey_shop_ids
      Survey.for_shop_ids(shop_ids).active.includes_shop.limit(limit_count).all
    end
  end

  def unanswered_surveys
    shop_ids = fetch_uanswered_survey_shop_ids
    Survey.for_shop_ids(shop_ids).active.includes_shop
  end

  def unanswered_surveys_count(force = false)
    cache_key = "unanswered-surveys-count-#{self.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.dashboard_count) do
      shop_ids = fetch_uanswered_survey_shop_ids
      Survey.for_shop_ids(shop_ids).active.count
    end
  end

  def adjust_labels(label_ids)
    existing_label_ids = self.user_labels.collect(&:label_id)

    destruction_values = existing_label_ids - label_ids
    new_values = label_ids - existing_label_ids

    UserLabel.transaction do
      self.user_labels.find_all_by_label_id(destruction_values).each { |user_label| user_label.destroy }
      new_values.each do |label_id|
        self.user_labels.create(label_id: label_id)
      end
    end
  end

  def build_permission_users
    Permission.scoped.map do |permission|
      permissions_users.new(:permission_id => permission.id)
    end
  end

  def visible_permissions_users
    permissions_users.select(&:action)
  end

  def permission_names
    permissions_users.select(&:action).collect(&:permission).collect(&:name)
  end

  def display_name
     permission_name || permission_email || "Optyn User"
  end

  def display_fullname
    display_name
  end

  def display_email
    permission_email || "N/A"
  end

  def image_url(omniauth_provider_id=nil)
    if !picture.blank?
      picture
    elsif (authentication = authentications.find_by_id(omniauth_provider_id)).present?
      url = authentication.image_url
      url.blank? ? "/assets/avatar.png" : url
    else
      "/assets/avatar.png"
    end
  end

  private
  def self.persist_with_twitter_exception(user, provider)
    user.skip_password = true
    if 'twitter' == provider
      user.save(validate: false)
    end
    user.save
  end

  def permission_name
    self.name if permissions_users.permission_visible?(Permission.name_id)
  end

  def permission_email
    self.email if permissions_users.permission_visible?(Permission.email_id)
  end

  def assign_office_zip_code(attrs)
    assign_zip_code(:office_zip_code, attrs)
  end

  def assign_home_zip_code(attrs)
    assign_zip_code(:home_zip_code, attrs)
  end

  def assign_zip_code(attr, attrs)
    if attrs[attr].present?
      code = attrs[attr].strip
      if code.length == 5
        self.send((attr.to_s + "=").to_sym, code)
      else
        self.errors.add(attr, "invalid")
      end
    end
  end

  def send_welcome_email
    Resque.enqueue(WelcomeMessageSender, :user, self.id, (show_password ? self.password : nil), (show_shop ? shop_identifier : nil))
  end

  def check_for_used_manager_email
    unless self.errors.include?(:email)
      manager = Manager.find_by_email(self.email)
      self.errors.add(:email, "already taken") if manager.present?
    end
  end

  def fetch_uanswered_survey_shop_ids
    connection_shop_ids = connections.active.collect(&:shop_id)
    survey_shop_ids = SurveyAnswer.uniq_shop_ids(self.id)
    connection_shop_ids - survey_shop_ids
  end
end
