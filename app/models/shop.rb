require 'embed_code_generator'
require 'shops/importer'

class Shop < ActiveRecord::Base
  include UuidFinder
  extend Shops::Importer

  acts_as_paranoid({column: 'deleted_at', column_type: 'time'})


  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription
  has_many :managers, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :users, through: :connections
  has_one :survey, dependent: :destroy
  has_many :interests, :as => :holder
  has_many :businesses, :through => :interests
  has_many :labels, dependent: :destroy
  has_many :shop_audits
  belongs_to :coupon
  belongs_to :partner

  SHOP_TYPES=['local', 'online']
  OPTYN_POSTFIX = 'Optyn Postfix'
  DEFAULT_HEADER_BACKGROUND_COLOR = '#1791C0'
  DEFUALT_TIMEZONE = "Eastern Time (US & Canada)"


  attr_accessible :name, :stype, :managers_attributes, :locations_attributes, :description, :logo_img, :upload_location, :business_ids, :website, :identifier, :time_zone, :virtual, :header_background_color, :phone_number, :remote_logo_img_url, :pre_added, :uploaded_directly


  mount_uploader :logo_img, ShopImageUploader

  validates_as_paranoid
  validates :name, presence: true, uniqueness:  { case_sensitive: false }
  validates :stype, presence: true, :inclusion => {:in => SHOP_TYPES, :message => "is Invalid"}
  validates :identifier, uniqueness: true, presence: true, unless: :new_record?
  validates :time_zone, presence: true, unless: :new_record?
  validates :phone_number, presence: true, unless: :virtual
  validates :phone_number, :phony_plausible => true 
  validates_uniqueness_of_without_deleted :name
  

  accepts_nested_attributes_for :managers
  accepts_nested_attributes_for :locations

  scope :includes_app, includes(:oauth_application)

  scope :inlcudes_locations, includes(:locations)

  scope :includes_managers, includes(:managers)

  scope :joins_locations, joins(:locations)

  scope :joins_businesses, joins(:businesses)

  scope :for_app_id, ->(app_id) { inlcudes_locations.includes_app.where(["oauth_applications.uid = :app_id", {app_id: app_id}]) }

  scope :fetch_same_identifier, ->(shop_id, q) { where(["shops.id <> :shop_id AND shops.identifier LIKE :q", {shop_id: shop_id, q: q}]) }

  scope :disconnected, ->(connected_ids) { where(["shops.id NOT IN (:exisiting_ids)", exisiting_ids: connected_ids]) }

  scope :for_zips, ->(zips, shop_ids) { disconnected(shop_ids).joins_locations.where(["locations.zip IN (:zips)", {zips: zips}]) }

  scope :for_businesses, ->(business_ids, shop_ids) { disconnected(shop_ids).joins_businesses.where(["businesses.id IN (:business_ids)", {business_ids: business_ids}]) }

  scope :real, where(virtual: false)

  scope :by_name, ->(shop_name) { where(["shops.name ILIKE :name", {name: shop_name}]) }

  scope :lower_name, ->(shop_name) { where(["LOWER(shops.name) LIKE LOWER(:shop_name)", {shop_name: shop_name}]) }

  before_validation :assign_identifier, :assign_partner_if, on: :create

  before_create :assign_identifier, :assign_partner_if, :assign_timezone_if

  after_create :assign_uuid, :create_dummy_survey, :create_select_all_label, :create_default_subscription

  set_callback :recover do
    self.deleted_at = nil
    self.time_zone = 
    self.save
    create_dummy_survey
    create_select_all_label
    assign_identifier
    create_default_subscription 
    true
  end


  #INDUSTRIES = YAML.load_file(File.join(Rails.root,'config','industries.yml')).split(',')

  def self.for_name(shop_name)
    lower_name(shop_name.to_s).first
  end

  def self.by_app_id(app_id)
    for_app_id(app_id).first
  end

  def self.disconnected_connections(connected_ids)
    return real.order(:name) if connected_ids.blank?
    real.disconnected(connected_ids).order(:name)
  end

  def self.search_or_add_by_domain(domain)
    sanitized_domain = sanitize_domain(domain)
    shop = find_by_name(sanitized_domain)
    unless shop.present?
      shop = Shop.new(name: sanitized_domain, virtual: true)
      shop.stype = "online"
      shop.save(validate: false)
    end

    if shop.managers.blank?
      manager = shop.managers.build
      puts "Email: #{"virtualmanager@#{shop.name}"}"
      manager.attributes=({name: "#{shop.name} Virtual Manager", email: "virtualmanager@#{shop.name}", password: "virtualmanager", password_confirmation: "virtualmanager", owner: true})
      manager.save!
    end

    shop
  end

  def self.optyn_magic
    for_name(OPTYN_POSTFIX)
  end

  def self.optyn_magic_manager
    optyn_magic.manager
  end

  def shop
    self
  end


  def update_with_existing_manager(attrs)
    Shop.transaction do
      manager_attrs = attrs['managers_attributes'].values.first
      existing_manager = managers.find_by_uuid(manager_attrs['uuid'])
      
      manager_attrs.delete('uuid')
      if manager_attrs['password'].blank? && manager_attrs['password_confirmation'].blank?
        manager_attrs.delete('password')
        manager_attrs.delete('password_confirmation')
      end

      existing_manager.attributes = manager_attrs
      existing_manager.save!
      self.attributes = attrs.except('managers_attributes')
      self.save!
    end
  end

  def shop_already_exists?
    Shop.where("name LIKE ?", self.name).count != 0
  end

  def update_manager
    self.managers.first.update_attributes(:owner => true)
  end

  def get_shop_owner
    self.managers.where(:owner => true).first
  end

  def is_subscription_active?
    is_online? || (is_local? && self.subscription && self.subscription.active?)
  end

  def is_local?
    self.stype == 'local'
  end

  def is_online?
    self.stype == 'online'
  end

  def first_location_street_address
    "#{first_location.street_address1}, #{first_location.street_address2}"
  end

  def first_location_city
    first_location.city rescue nil
  end

  def first_location_state_name
    first_location.state_name rescue nil
  end

  def first_location_zip
    first_location.zip rescue ""
  end

  def button_display?
    [1, 2].include?(oauth_application.call_to_action.to_i)
  end

  def display_bar?
    1 == oauth_application.render_choice.to_i
  end

  def increment_button_impression_count
    self.button_impression_count = button_impression_count.to_i + 1
    self.save(validate: false)
  end

  def increment_button_click_count
    self.button_click_count = self.button_click_count.to_i + 1
    self.save(validate: false)
  end

  def increment_email_box_impression_count
    self.email_box_impression_count = email_box_impression_count.to_i + 1
    self.save(validate: false)
  end

  def increment_email_box_click_count
    self.email_box_click_count = self.email_box_click_count.to_i + 1
    self.save(validate: false)
  end

  def generate_oauth_token(options, force=false)
    app = nil
    if force
      oauth_application.destroy
      reload
    end

    app = self.oauth_application
    if app.present?
      set_app_attrs(app, options)
      app.save!
      assign_embed_code(app)
      app.save!
    else
      generate_application(options)
    end
  end

  def api_welcome_details
    details = as_json(only: "name")
    details[:user_count] = users.count

    details[:location] = {}

    useful_location = first_location
    if useful_location.present?
      details[:location] = useful_location.as_json(except: [:id, :created_at, :updated_at, :longitude, :latitude])
    end

    details[:button_url] = SiteConfig.app_base_url + "/assets/" + (oauth_application.call_to_action == 1 ? 'optyn_button_small.png' : 'optyn_button_large.png')

    # put the oauth details
    details[:welcome_message] = oauth_application.show_default_optyn_text ? SiteConfig.api_welcome_message : oauth_application.custom_text

    details
  end

  def app_id
    self.oauth_application.uid
  end

  def secret
    self.oauth_application.secret
  end

  def redirect_uri
    self.oauth_application.redirect_uri
  end

  def business_category_names
    businesses.collect(&:name)
  end

  def inactive_label
    labels.inactive(self).first
  end

  def get_connection_for_user(user)
    self.connections.where(:user_id => user.id)
  end

  def first_location
    locations.first rescue nil
  end

  def opt_ins_via_button
    connections.connected_via_optyn_button.count
  end

  def opt_ins_via_email_box
    connections.connected_via_email_box.count
  end

  def email_box_conversion_percent
    ((100 / email_box_impression_count.to_f) * opt_ins_via_email_box.to_f) #rescue "N/A"
  end

  def has_logo?
    logo_img?
  end

  def logo_location
    return "https://#{SiteConfig.bucket}.s3.amazonaws.com/uploads" + upload_location if uploaded_directly

    logo_img? ? logo_img_url : nil rescue "#{}"
  end

  def active_connections
    connections.where('active IS TRUE')
  end

  def active_connection_count
    active_connections.count
  end

  def tier_change_required?
    self.plan.max < self.active_connection_count
  end

  def upgrade_plan
    new_plan = Plan.which(self)
    self.subscription.update_plan(new_plan)
    Resque.enqueue(PaymentNotificationSender, "MerchantMailer", "notify_plan_upgrade", {manager_id: self.manager.id})
    create_audit_entry("Subscription updated to plan #{new_plan.name}")
  end

  def check_subscription
    if !self.virtual
      if self.active_connection_count == (Plan.starter.max + 1) && self.is_subscription_active?
        Resque.enqueue(PaymentNotificationSender, "MerchantMailer", "notify_passing_free_tier", {manager_id: self.manager.id})
      elsif !self.virtual && self.tier_change_required?
        self.upgrade_plan
      end
    end
  end

  def self.batch_check_subscriptions
    all.each { |shop| shop.check_subscription }
  end

  def disabled?
    return false if self.coupon.present? && self.coupon.free_forever?
    return false if !self.partner.subscription_required?
    (Plan.which(self) != Plan.starter and !self.subscription.active) # rescue false
  end

  def create_audit_entry(message)
    self.shop_audits.create(:description => message)
  end

  def manager
    managers.owner.first || managers.first
  end

  def set_header_background(color_hex)
    shop.header_background_color = color_hex
    shop.save(validate: false)
  end

  def partner_optyn?
    self.partner.optyn?
  end

  def error_messages
    self.errors.full_messages
  end  
  

  private
  def self.sanitize_domain(domain_name)
    domain_name.gsub(/(https?:\/\/)?w{3}\./, "").downcase
  end

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
    self.save(validate: false)
  end

  def create_dummy_survey
    unless self.virtual?
      unless survey.present?
        dummy_survey = self.build_survey
        dummy_survey.shop_id = self.id
        dummy_survey.add_canned_questions
        dummy_survey.save(validate: false)
        dummy_survey
      else
        survey
      end
    end
  end

  def create_select_all_label
    unless self.virtual?
      label = Label.find_or_initialize_by_shop_id_and_name(self.id, Label::SELECT_ALL_NAME)
      label.active = false
      label.save
    end
  end

  def assign_identifier
    unless self.virtual?
      if self.identifier.blank? || (self.new_record? && (shop = Shop.find_by_identifier(self.identifier)).present?)
        self.identifier = self.name.parameterize
        while (shop = Shop.find_by_identifier(self.identifier)).present?
          self.identifier = self.name.parameterize + "-" + Devise.friendly_token.first(8).downcase
        end
      end
    end
  end

  def assign_partner_if
    if self.partner.blank?
      self.partner_id = Partner.optyn_id
    end
  end

  def assign_timezone_if
    if self.time_zone.blank?
      self.time_zone = DEFUALT_TIMEZONE
    end
  end

  def generate_application(options)
    Shop.transaction do
      app = Doorkeeper::Application.new(:name => self.name + self.first_location_zip)
      set_app_attrs(app, options)
      app.save

      assign_embed_code(app)
      app.save

      self.oauth_application = app
    end
  end

  def set_app_attrs(app, options)
    app.redirect_uri = options[:redirect_uri]
    app.owner = self
    app.call_to_action = options[:call_to_action]
    app.render_choice = options[:render_choice]
    app.checkmark_icon = options[:checkmark_icon]
    app.show_default_optyn_text = options[:show_default_optyn_text]
    app.custom_text = options[:custom_text]
    app.begin_state = options[:begin_state]
    app.background_color = options[:background_color]
  end

  def assign_embed_code(app)
    app.embed_code = EmbedCodeGenerator.generate_embed_code(app)
  end

  def create_default_subscription
    unless shop.virtual
      shop_subscription = Subscription.find_or_initialize_by_shop_id(self.id)
      if shop_subscription.new_record?
        shop_subscription.attributes = {:plan_id => Plan.starter.id, :active => false, :email => self.manager.email}
      end
      shop_subscription.save
      create_audit_entry('subscribed to default/starter plan')
    end
  end
end
