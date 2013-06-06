require 'embed_code_generator'

class Shop < ActiveRecord::Base

  has_one :subscription, dependent: :destroy
  has_many :managers, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :users, through: :connections
  has_one :survey, dependent: :destroy
  has_many :interests, :as => :holder
  has_many :businesses, :through => :interests
  has_many :labels, dependent: :destroy

  SHOP_TYPES=['local', 'online']
  attr_accessible :name, :stype, :managers_attributes, :locations_attributes, :description, :logo_img, :business_ids, :website, :identifier, :time_zone
  mount_uploader :logo_img, ImageUploader

  validates :name, :presence => true
  validates :stype, :presence => true, :inclusion => {:in => SHOP_TYPES, :message => "is Invalid"}
  validates :identifier, uniqueness: true, presence: true, unless: :new_record?
  validates :time_zone, presence: true, unless: :new_record?

  accepts_nested_attributes_for :managers
  accepts_nested_attributes_for :locations

  scope :includes_app, includes(:oauth_application)

  scope :inlcudes_locations, includes(:locations)

  scope :joins_locations, joins(:locations)

  scope :joins_businesses, joins(:businesses)

  scope :for_app_id, ->(app_id) { inlcudes_locations.includes_app.where(["oauth_applications.uid = :app_id", {app_id: app_id}]) }

  scope :fetch_same_identifier, ->(shop_id, q) { where(["shops.id <> :shop_id AND shops.identifier LIKE :q", {shop_id: shop_id, q: q}]) }

  scope :disconnected, ->(connected_ids) { where(["shops.id NOT IN (:exisiting_ids)", exisiting_ids: connected_ids]) }

  scope :for_zips, ->(zips, shop_ids) { disconnected(shop_ids).joins_locations.where(["locations.zip IN (:zips)", {zips: zips}]) }

  scope :for_businesses, ->(business_ids, shop_ids) { disconnected(shop_ids).joins_businesses.where(["businesses.id IN (:business_ids)", {business_ids: business_ids}]) }

  after_create :create_dummy_survey, :create_select_all_label, :assign_identifier

  #INDUSTRIES = YAML.load_file(File.join(Rails.root,'config','industries.yml')).split(',')

  def self.by_app_id(app_id)
    for_app_id(app_id).first
  end

  def self.disconnected_connections(connected_ids)
    return order(:name) if connected_ids.blank?
    disconnected(connected_ids).order(:name)
  end

  def shop
    self
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

  def increment_impression_count
    self.button_impression_count = button_impression_count.to_i + 1
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

    details[:button_url] = SiteConfig.app_base_url + "/assets/" + (oauth_application.button_size == 1 ? 'optyn_button_small.png' : 'optyn_button_large.png')

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

    
  def self.unfollowed_connections(shop_id)
    shop = Shop.find(shop_id) 
    cache_key = "dashboard-unfollowed-connections-shop-#{shop_id}"
    Rails.cache.fetch(cache_key, :expires_in => SiteConfig.ttls.dashboard_count) do
      Connection.for_shop(1).inactive.order('updated_at desc')
    end
  end

  def first_location
    locations.first rescue nil
  end

  private
  def create_dummy_survey
    unless survey.present?
      dummy_survey = Survey.new
      dummy_survey.shop_id = self.id
      dummy_survey.add_canned_questions
      dummy_survey.save(validate: false)
      dummy_survey
    else
      survey
    end
  end

  def create_select_all_label
    label = Label.new(shop_id: self.id, name: Label::SELECT_ALL_NAME)
    label.active = false
    label.save
  end

  def assign_identifier
    if self.identifier.blank?
      self.identifier = self.name.parameterize
      self.save(validate: false)
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
    app.button_size = options[:button_size]
    app.checkmark_icon = options[:checkmark_icon]
    app.show_default_optyn_text = options[:show_default_optyn_text]
    app.custom_text = options[:custom_text]
  end

  def assign_embed_code(app)
    app.embed_code = EmbedCodeGenerator.generate_embed_code(app)
  end

  
end
