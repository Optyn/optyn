require 'embed_code_generator'
require 'shops/importer'
require 'shops/eatstreet_rules'

class Shop < ActiveRecord::Base
  include UuidFinder
  extend Shops::Importer
  include Shops::ShopCreditor
  extend AppDefaultCss

  acts_as_paranoid({column: 'deleted_at', column_type: 'time'})


  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription
  has_many :managers, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :users, through: :connections
  has_many :interests, :as => :holder
  has_many :businesses, :through => :interests
  has_many :labels, dependent: :destroy
  belongs_to :coupon
  belongs_to :partner
  has_many :social_profiles, dependent: :destroy

  has_many :surveys, dependent: :destroy #changing it to has_many
  has_many :templates, dependent: :destroy

  delegate :embed_code, :show_form, to: :oauth_application

  SHOP_TYPES=['local', 'online']
  OPTYN_POSTFIX = 'Optyn Postfix'
  DEFAULT_HEADER_BACKGROUND_COLOR = '#1791C0'
  DEFAULT_FOOTER_BACKGROUND_COLOR = '#ffffff'
  DEFUALT_TIMEZONE = "Eastern Time (US & Canada)"

  APP_BEGIN_STATE_HIDDEN = '0'
  APP_RENDER_CHOICE_BAR = 1

  attr_accessible :name, :stype, :managers_attributes, :locations_attributes, :description, :logo_img
  attr_accessible  :pre_added, :business_ids, :website, :identifier, :time_zone, :virtual
  attr_accessible :header_background_color, :phone_number, :remote_logo_img_url 
  #attr_accessible :uploaded_directly, :upload_location,
  attr_accessible :footer_background_color, :verified_email, :ses_verified
  attr_accessor :skip_payment_email 


  mount_uploader :logo_img, ShopImageUploader

  validates_as_paranoid
  validates :name, presence: true , uniqueness:  { case_sensitive: false, if: :virtual}
  validates :stype, presence: true, :inclusion => {:in => SHOP_TYPES, :message => "is Invalid"}
  validates :identifier, uniqueness: true, presence: true, unless: :new_record?
  validates :time_zone, presence: true, unless: :new_record?
  validates :phone_number, presence: true, unless: :virtual, length: {minimum: 10, maximum: 20}
  validates :phone_number, :phony_plausible => true 
  validate :validate_website

  

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

  scope :by_manager_email, ->(manager_email) {joins(:managers).where(["managers.email LIKE LOWER(:manager_email)", {manager_email: manager_email}])}

  scope :not_pre_added, where(pre_added: false)

  scope :alphabetized, order("shops.name")

  before_validation :assign_identifier, :assign_partner_if, on: :create

  before_create :assign_identifier, :assign_partner_if, :assign_timezone_if, :assign_header_background_color, :assign_footer_background_color

  after_create :assign_uuid, :create_dummy_survey, :create_select_all_label, :create_default_subscription

  delegate :stripe_customer_token, to: :subscription

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

  def self.for_manager_email(manager_email)
    by_manager_email(manager_email).first
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

  def display_website
    if self.website.present?
      unless self.website[/\Ahttp:\/\//] || self.website[/\Ahttps:\/\//]
        self.website = "http://#{self.website}"
      else
        self.website
      end
    end
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

  def form_code
    if 1 == oauth_application.render_choice.to_i
      wrapper_style = %Q(<style type="text/css">
                    #optyn_button_wrapper { background-color: #{oauth_application.background_color}; margin: 0px; height: 60px; vertical-align: middle; border-bottom:thick solid #046d95; border-width: 2px;}
                    #show_optyn_button_wrapper { background-color: #{oauth_application.background_color}; background-position: 0 -8px; display: block; height: 40px; /*overflow: hidden;*/ padding: 16px 0 0; position: absolute; right: 20px; top: -3px; width: 80px; z-index: 100; box-shadow: 0 0 5px rgba(0,0,0,0.35); -moz-box-shadow: 0 0 5px rgba(0,0,0,0.35); -webkit-box-shadow: 0 0 5px rgba(0,0,0,0.35); border-bottom-right-radius: 5px; border-bottom-left-radius: 5px; border: 2px solid #046d95; text-align: center; }
                  </style>)
    end

    app = self.oauth_application 
    name_field = '<input type="text" id="user_name" name="user[name]" size="34" placeholder="enter name">' if self.oauth_application.show_name?
    %Q(
       <style type="text/css">#{self.oauth_application.custom_css}</style>
       #{wrapper_style}
       <div id="optyn_button_wrapper">
        #{app_form_welcome_message}
        <div id="optyn-container">     
           <div id="optyn-first-container">
            <form method="post" action="#{SiteConfig.app_base_url}/authenticate_with_email" id="optyn-email-form">
              #{name_field}
              <input placeholder="enter your e-mail" size="34" name="user[email]" id="user_email" type="email">
              <input value="#{app.uid}" name="app_id" id="app_id" type="hidden">
              <input value="Subscribe" name="commit" id="commit" type="submit">
            </form>
           </div>
        </div>
       </div>
    )
  end

  def app_form_welcome_message
    if app_render_bar_choice?
      <<-HTML
        <div class="optyn-text">#{app_text_blurb}</div>
      HTML
    end
  end

  def starter_plan?
    plan.id == Plan.starter.id
  rescue
    false
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

  def customer_token_available?
    subscription.present? && subscription.stripe_customer_token.present?
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

  def message_address
    "#{name} | #{first_location_street_address} | #{first_location_city}, #{first_location_state_name} #{first_location_zip}"
  end

  def button_display?
    [1, 2].include?(oauth_application.call_to_action.to_i) rescue false
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
    details[:welcome_message] = app_text_blurb

    details
  end

  def app_text_blurb
    oauth_application.show_default_optyn_text ? SiteConfig.api_welcome_message : oauth_application.custom_text
  end

  def app_id
    self.oauth_application.uid
  end

  def app_render_bar_choice?
    APP_RENDER_CHOICE_BAR == oauth_application.render_choice.to_i 
  end

  def app_begin_state_hidden?
    APP_BEGIN_STATE_HIDDEN == oauth_application.begin_state.to_i
  end

  def secret
    self.oauth_application.secret
  end

  def redirect_uri_after_login
    self.oauth_application.redirect_uri_after_login
  end
  
  def redirect_uri
    self.oauth_application.redirect_uri
  end

  def business_category_names
    businesses.collect(&:name)
  end

  def inactive_label
    labels.defult_message_label(self)
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

    logo_img? ? logo_img_url : nil rescue "#{}"
  end

  def active_connections
    connections.where('active IS TRUE')
  end

  def active_connection_count
    active_connections.count
  end

  def tier_change_required?
    self.plan.max < self.active_connection_count || self.plan.min > self.active_connection_count
  end

  def upgrade_plan
    #the function that actually does plan change
    new_plan = Plan.which(self)
    #binding.pry
    plan_downgraded = self.plan_downgraded?
    self.subscription.update_plan(new_plan)

    #Send Plan upgrade mail, only when plan is upgraded.
    if !self.skip_payment_email && !plan_downgraded
      conn_count = self.active_connection_count
      PaymentNotificationSender.perform_async("MerchantMailer", "notify_plan_upgrade", {manager_id: self.manager.id, active_connections: conn_count})
    end
  end

  def check_subscription
    #the function thats  checks if plan change is requried after importing connections
    #Calls tier_change_upgrade_planrequired and upgrade_plan
    #Called by Connection > check_shop_tier
    if !self.virtual && self.partner.subscription_required?

      if self.tier_change_required?
        
        #Notify passing of free tier mail
        if !self.skip_payment_email && self.active_connection_count == (Plan.starter.max + 1) && self.is_subscription_active?
          PaymentNotificationSender.perform_async("MerchantMailer", "notify_passing_free_tier", {manager_id: self.manager.id})
        end
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

  def partner_eatstreet?
    self.partner.eatstreet?
  end

  def error_messages
    self.errors.full_messages
  end  
  
  def meta_tag_title
    content = "Get Info About #{name} Here"

    if first_location.present?
      content << " in #{first_location_city}" if first_location_city.present?
      content << ", #{first_location_state_name}" if first_location_state_name.present?
    end
    
    content
  end

  def meta_tag_description
    content = "Check out what type of marketing Promotions are available for #{name}, who uses Optyn to create coupons, specials, sales, surveys, and much more."

    if description.present?
      content << description 
    else
      content << %{Check out what type of marketing Promotions are available for #{name}, who uses Optyn to create coupons, specials, sales, surveys, and much more.}
    end

    content
  end

  def meta_tag_keywords
    content = []
    content << name
    content << meta_tag_title.gsub(/,/, " -")
    content.join(", ")
  end


  def upcoming_payment_amount_in_dollars
    plan_amount = plan.amount

    if coupon.present? && coupon.applicable?
      if coupon.percent_off.present?
        plan_amount = plan_amount * (coupon.percent_off.to_f / 100)
      else
        plan_amount = plan_amount - coupon.amount_off
      end 
    end

    plan_amount.to_f / 100
  end

  def with_missing_profiles
    existing_profiles = social_profiles.all #calling all to get an array but relation
    blank_profiles_map = SocialProfile.all_types_map(self.id)

    existing_profiles.each do |profile|
      blank_profiles_map.delete(profile.sp_type)
    end

    existing_profiles + blank_profiles_map.values
  end

  def plan_downgraded?
    if self.plan.min > self.active_connection_count
      return true
    else
      return false
    end
  end

  private
  def add_website_scheme
    self.website = "http://" + self.website if self.website.present? && !self.website.match(/^https?:\/\//)
  end

  def self.sanitize_domain(domain_name)
    domain_name.gsub(/(https?:\/\/)?w{3}\./, "").downcase
  end

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
    self.save(validate: false)
  end

  def create_dummy_survey
    unless self.virtual?
      unless surveys.present?
        dummy_survey = self.surveys.build
        dummy_survey.shop_id = self.id
        dummy_survey.ready = false
        dummy_survey.title = "Default Survey"
        dummy_survey.add_canned_questions
        dummy_survey.save(validate: false)
        dummy_survey
      else
        surveys
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

  def assign_header_background_color
    self.header_background_color = partner.header_background_color if self.header_background_color.blank?
  end

  def assign_footer_background_color
    self.footer_background_color = partner.footer_background_color
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
    app.redirect_uri_after_login = options[:redirect_uri_after_login]
    app.custom_css = options[:custom_css]
    app.label_ids = options[:label_ids]
    app.show_name = options[:show_name]
    app.show_form = options[:show_form]
  end

  def assign_embed_code(app)
    app.embed_code = EmbedCodeGenerator.generate_embed_code(app)
  end

  def create_default_subscription
    unless self.virtual
      if partner.subscription_required?
        shop_subscription = Subscription.find_or_initialize_by_shop_id(self.id)
        if shop_subscription.new_record?
          shop_subscription.attributes = {:plan_id => Plan.starter.id, :active => false, :email => self.manager.email}
        end
        shop_subscription.save
      end
    end
  end

  def validate_website
    if website.present?
      add_website_scheme

      if !(URI.parse(self.website) rescue false) || !(self.website.match(/^(https?:\/\/(w{3}\.)?)|(w{3}\.)|[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix))
        self.errors.add(:website, "is invalid. Here is an example: www.example.com")
      end
    end
  end

end #end of class Shop
