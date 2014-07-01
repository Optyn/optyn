require 'messagecenter/process_manager'
require 'tracking_services/messages'

class Message < ActiveRecord::Base
  include UuidFinder
  include Shops::EatstreetRules
  include Messagecenter::MessageExtension
  
  belongs_to :manager
  has_many :message_labels, dependent: :destroy
  has_many :labels, through: :message_labels
  has_many :message_users, dependent: :destroy
  has_many :message_email_auditors, dependent: :destroy
  belongs_to :survey
  has_many :message_visual_properties, dependent: :destroy
  has_one :message_image, dependent: :destroy
  has_many :redeem_coupons, dependent: :destroy
  belongs_to :template, :class_name => "Template", :with_deleted => true


  has_many :children, class_name: "Message", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Message", foreign_key: :parent_id

  attr_accessor :unread, :ending_date, :ending_time, :send_date, :send_time, :send_on_date, :send_on_time, :send_on_rounded

  attr_accessible :label_ids, :name, :subject, :send_immediately, :send_on, :send_on_date, :send_on_time, :message_visual_properties_attributes, :button_url, :button_text, :message_image_attributes, :ending_date, :ending_time, :manager_id, :make_public, :template_id
 
  accepts_nested_attributes_for :message_visual_properties, allow_destroy: true
  accepts_nested_attributes_for :message_image, allow_destroy: true

  FIELD_TEMPLATE_TYPES = ["coupon_message", "event_message", "general_message", "product_message", "sale_message", "special_message", "survey_message", "template_message"]
  DEFAULT_FIELD_TEMPLATE_TYPE = "general_message"
  COUPON_FIELD_TEMPLATE_TYPE = "coupon_message"
  EVENT_FIELD_TEMPLATE_TYPE = "event_message"
  PRODUCT_FIELD_TEMPLATE_TYPE = "product_message"
  SALE_FIELD_TEMPLATE_TYPE = "sale_message"
  SPECIAL_FIELD_TEMPLATE_TYPE = "special_message"
  SURVEY_FIELD_TEMPLATE_TYPE = "survey_message"
  TEMPLATE_FIELD_TEMPLATE_TYPE = "template_message"
  PER_PAGE = 50
  PAGE = 1
  MESSAGE_BATCH_SEND_NAME = "message_batch_send.pid"
  FORWARD_MESSAGE_BATCH_SEND_NAME = "forward_message_batch_send.pid"
  SIDEBAR_TEMPLATS = ["Left Sidebar", "Right Sidebar"] 
  HERO_TEMPLAT = ["Hero"]

  after_initialize :assign_canned_subject, :if => 'subject.blank?'

  # check for validations explicityly with valid?() as in draft state save() has validate: false
  # save() is overriden somewhere in the code below
  before_create :assign_uuid, :valid?

  after_create :assign_parent_state_if

  validates :name, presence: true, unless: :shop_virtual?
  validate :send_on_greater_by_hour
  
  with_options :on => :update do |m|
    m.validates :subject, presence: true
    m.validate :validate_child_message
    m.validate :validate_button_url
    m.validate :validate_recipient_count
  end

  scope :only_parents, where(parent_id: nil)

  scope :for_state_and_shop, ->(state_name, shop_id) { only_parents.with_state(state_name).joins(manager: :shop).where(["shops.id = :shop_id", {shop_id: shop_id}]) }

  scope :for_uuids, ->(uuids) { where(uuid: uuids) }

  scope :latest, order("messages.updated_at DESC")

  scope :ready_messages, ->() { where(["messages.send_on < :less_than_a_minute", {less_than_a_minute: 1.minute.since}]) }

  scope :includes_message_users, includes(:message_users)

  scope :active_state, where("messages.state NOT IN ('delete', 'trash')")

  scope :made_public, where(make_public: true)

  scope :scheduled_inrange, ->(range) { where(send_on: range) }

  scope :not_for_ids, ->(ids) { where(["messages.id NOT IN (:ids)", {ids: ids}]) }

  state_machine :state, :initial => :draft do

    event :save_draft do
      transition :draft => same
    end

    event :save_and_navigate_parent do
      transition :draft => same
    end

    event :preview do
      transition :draft => same, :queued => same, :pending_approval => same
    end

    event :launch do
      transition [:pending_approval, :draft, :queued] => :queued, :if => :valid?
    end

    event :move_to_trash do
      transition [:pending_approval, :draft, :queued, :sent, :trash] => :trash
    end

    event :move_to_draft do
      transition [:queued, :trash] => :draft
    end

    event :discard do
      transition [:trash, :draft] => :delete
    end

    event :start_transit do
      transition :queued => :transit
    end

    event :deliver do
      transition [:queued, :transit] => :sent
    end

    event :reject do
      transition [:pending_approval,:queued] => :draft
    end

    event :send_for_approval do
      transition [:pending_approval,:queued,:draft] => :pending_approval
    end

    before_transition :draft => same do |message|
      message.subject = message.send(:canned_subject) if message.subject.blank?
      message.from = message.send(:canned_from)    
      unless message.is_child?
        message.adjust_send_on
      else
        message.send_on = nil
      end
      # the explicit check for presence of name is required to ensure campaign name cannot be
      # set to blank even for an existing message record
      valid = message.valid? if message.new_record? || message.name.blank?
      #clear out errors other than those needed on the metadata page
      message.clear_errors_except('name', 'send_on')
      valid
    end

    before_transition :draft => :queued do |message|
      message.subject = message.send(:canned_subject) if message.subject.blank?
      message.from = message.send(:canned_from)
      
      message.valid?
    end

    before_transition any => :queued do |message|
      message.subject = message.send(:canned_subject) if message.subject.blank?
      message.from = message.send(:canned_from)
      
      unless message.is_child?
        message.adjust_send_on
      else
        message.send_on = nil
      end

      message.valid?
    end

    before_transition any => :pending_approval do |message|
      if message.partner_eatstreet?
        message.subject = message.send(:canned_subject) if message.subject.blank?
        message.from = message.send(:canned_from)
        
        unless message.is_child?
          message.adjust_send_on
        else
          message.send_on = nil
        end

        message.valid?
      end
    end

    before_transition :queued => :draft, :do => :remove_greeting

    after_transition any => :draft, :do => :replenish_draft_and_queued_count

    after_transition any => :queued, :do => :replenish_draft_and_queued_count

    after_transition any => :pending_approval, :do => :replenish_draft_and_queued_count

    after_transition any => :delete, :do => :replenish_draft_and_queued_count

    after_transition any => :trash, :do => :replenish_draft_and_queued_count

    after_transition any => any, :do => :transfer_child_state

    after_transition any => :sent, :do => :adjust_shop_credits #Adjust Eatstreets shop credits

    state :draft, :trash, :delete do
      def save(options={})
        super(validate: false)
      end
    end
  end

  def message_url(shop)
    msg = "#{self.name} #{self.uuid}"
    "#{SiteConfig.email_app_base_url}/#{shop.name.parameterize}/campaigns/#{msg.parameterize}"
  end

  def self.fetch_template_name(params_type)
    FIELD_TEMPLATE_TYPES.include?(params_type.to_s) ? params_type : DEFAULT_FIELD_TEMPLATE_TYPE
  end

  def self.fetch_human_non_survey_template_names
    (FIELD_TEMPLATE_TYPES - [SURVEY_FIELD_TEMPLATE_TYPE, TEMPLATE_FIELD_TEMPLATE_TYPE]).collect { |message| message.gsub('_message', '').titleize }
  end

  def self.type_from_human(type_name)
    type_name.downcase.parameterize.underscore.<<("_message")
  end

  def self.paginated_drafts(shop, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_shop(:draft, shop.id).latest.page(page_number).per(per_page)
  end

  def self.paginated_approves(shop, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_shop(:pending_approval, shop.id).latest.page(page_number).per(per_page)
  end

  def self.paginated_trash(shop, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_shop(:trash, shop.id).latest.page(page_number).per(per_page)
  end

  def self.paginated_sent(shop, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_shop(:sent, shop.id).latest.page(page_number).per(per_page)
  end

  def self.paginated_queued(shop, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_shop(:queued, shop.id).latest.page(page_number).per(per_page)
  end

  def self.cached_drafts_count(shop, force=false)
    cache_key = "draft-count-manager-#{shop.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.message_folder) do
      for_state_and_shop(:draft, shop.id).count
    end
  end

  def self.cached_queued_count(shop, force=false)
    cache_key = "queued-count-manager-#{shop.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.message_folder) do
      for_state_and_shop(:queued, shop.id).count
    end
  end

  def self.cached_approves_count(shop, force=false)
    cache_key = "approves-count-manager-#{shop.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.message_folder) do
      for_state_and_shop(:pending_approval, shop.id).count
    end
  end

  def self.move_to_trash(uuids)
    trigger_event(uuids, 'move_to_trash')
  end

  def self.move_to_draft(uuids)
    trigger_event(uuids, 'move_to_draft')
  end

  def self.discard(uuids)
    trigger_event(uuids, 'discard')
  end

  def self.batch_send
    messages = with_state([:queued]).only_parents.ready_messages
    execute_send(messages)
  end

  def self.batch_send_responses
    messages = with_state([:transit]).ready_messages
    execute_send(messages)
  end

  def self.create_response_message(user_id, message_uuid)
    message = Message.for_uuid(message_uuid)

    if message.present? && message.has_children?
      response_message = message.first_response_child
      response_message_keys = response_message.attributes.except('id', 'created_at', 'updated_at', 'uuid', 'send_on', 'type', 'state').keys
      individual_message = response_message.type.classify.constantize.new()

      individual_message.send_on = 100.minutes.since

      response_message_keys.each do |key|
        individual_message.send("#{key}=".to_sym, response_message.send(key.to_sym))
      end

      individual_message.save!

      individual_message.send_on = Time.now
      individual_message.state = 'transit'
      individual_message.save(validate: false)

      MessageUser.create_message_receiver_entries(individual_message, [user_id], [], nil)
    end

  end

  def self.get_qr_code_link(message_id)
    TrackingServices::Messages.qr_code(message_id)
  end

  def assign_canned_subject
    self.subject = canned_subject
  end

  def email_self
    clear_cached_template #clear the template cache

    SelfEmailSender.perform_async(self.id)
  end

  def copy_message
    message = self.class.new
    self.attributes.except('updated_at','created_at','id','uuid','send_on','name','state').each do |key, value|
      message.send("#{key}=", self.send(key.to_sym))
    end
    message.send("name=", "#{name} (copy #{Date.today.strftime("%m/%d/%Y")})")
    message.save_draft

    ##using same labels for new messsage
    self.label_ids.each do |label_id|
      message.message_labels.build(label_id: label_id, shop_identifier: self.shop_id)
    end
    
    message.save
    message
  end

  def assign_template(template_identifier, name=nil, properties={})
    unless self.template_id.present?
      existing_template = Template.for_uuid(template_identifier)
      self.template_id = existing_template.system_generated ? Template.copy(existing_template.id, name, shop, properties) : template_id_assigned = existing_template.id
      
      begin
        template_image = TemplateImage.find(properties.header.template_header_image_id)
        template_image.update_attributes(template_id: self.template_id)
      rescue
      end

      self.save(validate: false)
    end
  end

  def update_meta
    valid?
    non_meta_attrs = attributes.keys - ['subject', 'send_on']
    non_meta_attrs.each do |attr|
      errors.delete(attr.to_sym)
    end

    save(validate: false) if self.errors.empty?
  end

  def save_template_content!(message_hash)
    containers = message_hash[:containers]
    layout_hash = HashWithIndifferentAccess.new(containers: [])
    introduction_container = containers.detect{|container| "introduction" == container['type']}
    content_container = containers.detect{|container| "content" == container['type']}
    footer_container = containers.detect{|container| "footer" == container['type']}  

    layout_hash[:containers] << introduction_container if introduction_container.present?
    layout_hash[:containers] << content_container if content_container.present?
    layout_hash[:containers] << footer_container if footer_container.present?

    self.content = layout_hash.to_json
    self.save(validate: false)
  end

  def adjust_send_on
    if self.send_on.blank? || self.send_on < 1.hour.since
      send_timestamp = Time.now + 1.hour
      send_timestamp = send_timestamp.min >= 30 ? (send_timestamp.end_of_hour + 30.minutes) : (send_timestamp.end_of_hour)
      self.send_on = send_timestamp 
      self.send_on_rounded = true
    end
  end

  def manager_email
    manager.email
  end

  def editable_state?
    return true if is_child?
    draft? || queued_editable? || pending_approval?
  end

  def editable_state_for_manager?
    return true if is_child?
    draft? || queued_editable?
  end

  def queued_editable?
    queued? && send_on > 1.hour.since
  end

  def showable?
    !draft?
  end

  def send_only_content?
    self.instance_of?(VirtualMessage)
  end

  def show_greeting?
    !self.instance_of?(VirtualMessage)
  end
  alias_method :show_banner?, :show_greeting?
  alias_method :show_footer?, :show_greeting?

  def shop
    manager.shop
  end

  def shop_id
    shop.id
  end

  def partner
    shop.partner
  end

  def partner_eatstreet?
    partner.eatstreet?
  end

  def message_user(user)
    message_users.find_by_user_id(user.id)
  end

  def label_ids(labels=[])
    label_identifiers = message_labels.pluck(:label_id)
    if label_identifiers.blank? && !self.shop.virtual?
      label_identifiers = [shop.inactive_label.id]
    end
    label_identifiers
  end

  def label_ids=(label_identifiers)
    identifiers = label_identifiers.select(&:present?)

    if new_record?
      build_new_message_labels(identifiers)
    else
      manipulate_existing_message_labels(identifiers)
    end
  end

  def label_names
    labels.collect(&:name)
  end

  def connections_count
    return shop.connections.active.count if self.labels.pluck(:name).include? Label::SELECT_ALL_NAME #return active count if select all is selected
    fetch_labeled_users(self.label_ids)
  end

  def in_preview_mode?(preview=true)
    preview || draft?
  end

  def shop_name
    shop.name
  end

  def sanitized_discount_amount
    discount_amount.to_s.gsub(/[^A-Za-z0-9]\./, "")
  end

  def percentage_off?
    discount_type = type_of_discount.to_s.to_sym
    !(:dollar_off == discount_type)
  end

  def dispatch(creation_errors=[], process_manager=nil)
    clear_cached_template
    receiver_ids = fetch_receiver_ids
    receiver_ids = receiver_ids.compact
    message_user_creations = MessageUser.create_message_receiver_entries(self, receiver_ids, creation_errors, process_manager)

    if message_user_creations.blank?
      self.state = 'sent'
      self.save(validate: false)
      replenish_draft_and_queued_count
      ""
    else
      message_user_creations
    end
  end

  def personalized_subject(receiver, preview = false)
    replace_customer_name(receiver, self.subject, preview)
  rescue => e
    "A message from #{shop.name}"
  end

  def generic_subject(preview = false)
    replace_customer_name(nil, self.subject, preview)
  end

  def personalized_greeting(receiver, preview = false)
    replace_customer_name(receiver, self.subject, preview)
  end

  def personalized_content(receiver, preview = false)
    replace_customer_name(receiver, self.content, preview)
  rescue
    self.content
  end

  def generate_greeting(receiver = nil)
    greeting_prefix = case
      when self.instance_of?(CouponMessage)
        "Great News"
      when self.instance_of?(SpecialMessage)
        "Great News"
      when self.instance_of?(SaleMessage)
        "Hi"
      when self.instance_of?(GeneralMessage)
        "Hello"
      when self.instance_of?(ProductMessage)
        "Hi"
      when self.instance_of?(EventMessage)
        "Event News"
      when self.instance_of?(SurveyMessage)
        "Your feedback is valuable"
      else
        "Hello"
    end

    greeting_suffix = (receiver.first_name rescue "{{Customer Name}}")
    "#{greeting_prefix} #{greeting_suffix}"
  end

  def excerpt
    self.content.to_s.truncate(250)
  end

  def first_response_child
    children.active_state.first unless self.new_record?
  end

  def has_children?
    first_response_child.present? rescue false
  end

  def has_redemption?
    [CouponMessage, SpecialMessage].include? self.class
  end

  def is_child?
    self.parent_id.present?
  end

  def first_child_message_name
    first_response_child.name rescue nil
  end

  def first_child_message_identifier
    first_response_child.uuid rescue nil
  end

  def intended_recipients
    message_users.count
  end

  def actual_recipients
    message_email_auditors.delivered.count
  end

  def open_emails
    message_users.any_read.include_user.collect(&:email)
  end

  def opens_count
    message_users.any_read.count
  end

  def unsubscribes_emails
    message_users.opt_outs.include_user.collect(&:email)
  end

  def opt_outs
    message_users.opt_outs.count
  end

  def bounced_emails
    message_email_auditors.bounced.includes_user.collect(&:user).collect(&:email)
  end

  def bounced
    message_email_auditors.bounced.count
  end

  def complaint_emails
    message_email_auditors.complaints.includes_user.collect(&:user).collect(&:email)
  end

  def complaints
    message_email_auditors.complaints.count
  end

  def relevance_count
    message_users.coupon_relevance.count
  end

  def relevance_emails
    message_users.coupon_relevance.include_user.collect(&:email)
  end

  def irrelavance_count
    message_users.coupon_irrelevance.count
  end

  def irrelavance_email
    message_users.coupon_irrelevance.include_user.collect(&:email)
  end

  def link_click_count
    EmailTracking.consolidated_count(self.id)
  end


  def error_messages
    self.errors.full_messages
  end

  def clear_errors_except(*exempted_attrs)
    (self.attribute_names - exempted_attrs).each { |attr| self.errors[attr].clear }
  end
    
  #Returning the default value for now.
  #Nothing to do with any message visual properties for now  
  def footer_background_color_css_val
    "background-color: " + shop.footer_background_color
  end

  def header_background_property
    header = MessageVisualProperty.header(self.id)

    header.blank? ? message_visual_properties.build(property_value: "background-color: #{shop.header_background_color.strip}") : header
  end

  def header_background_color_css_val
    property = self.header_background_property
    return "background-color: #{shop_header_background_color_hex};" if property.present? && (property.instance_of?(ActiveRecord::Relation) ? property.first : property).new_record?
    css = "#{self.header_background_property.property_value};"
    css
  end

  def header_background_color_hex
    header_background_color_css_val.split(/:/).last.to_s.gsub(/;/, "").strip
  end

  def header_background_color_property_present?
    !(header_background_property.new_record?)
  end

  def header_background_color_property_id
    header_background_property.id
  end

  def update_visuals(options={})
    Message.transaction do 
      # update_attributes!(options)
      self.attributes = options
      preview
      if options['message_visual_properties_attributes']['0']['make_default'].to_s == "1"
        hex = self.header_background_color_hex
        shop.set_header_background(hex)
      end
    end
  end

  def shop_header_background_color_hex
    self.shop.header_background_color.strip
  end

  def show_image?
    message_image.present?    
  end

  def image_location
    if show_image?
      message_image.image.url
    end
  end

  def share_image_location
    #Can be overridden based on Message Type
    shop.has_logo? ? shop.logo_location : "http://placehold.it/200x200.png&text=#{shop.name}"
  end

  def show_button?
    button_url.present? && button_text.present?
  end

  def display_button_link
    button_url
  end

  def call_fb_api(link)
    response = HTTParty.get("#{FACEBOOK_STAT_API}" + link + "&format=json")
    # response = HTTParty.get("https://api.facebook.com/method/links.getStats?urls=https://development.optyn.com/music-store/campaigns/testing-share-stat-ac49bdfcf8d345e1b2872505eea9e0f6&format=json")
    return response.parsed_response
  end

  def call_twitter_api(link)
    response = HTTParty.get("#{TWITTER_STAT_API}" + link)
    # response = HTTParty.get("http://urls.api.twitter.com/1/urls/count.json?url=https://development.optyn.com/music-store/campaigns/test-coupon-3141d0567770402b8e7084bc495018f4")
    return response.parsed_response
  end

  def message_send?
    return true unless Rails.env.staging?
    return true if Rails.env.staging? && (self.partner.eatstreet? || MessageStagingEmail.approved_emails.include?(self.manager.email))
  end

  private
  def self.trigger_event(uuids, event)
    messages = for_uuids(uuids)
    Message.transaction do
      messages.each do |message|
        message.send(event.to_s.to_sym)
      end
    end
  end

  def self.execute_send(messages)
    process_manager = Messagecenter::ProcessManager.new(
        :current_pid_file_name => MESSAGE_BATCH_SEND_NAME,
        :relevant_pid_names => [FORWARD_MESSAGE_BATCH_SEND_NAME],
        :content => lock_file_content(messages)
    )
    unless messages.blank?
      if process_manager.no_lock_file?
        process_manager.create_pid_file
        creation_errors = []
        processing_errors = []

        #Iterating through the messages and creating message and attachments for individual receivers
        messages.each do |message|
          #message.state = 'transit'
          #message.save(validate: false)
          if !message.shop.disabled? && message.message_send?

            dispatched_message = message.dispatch(creation_errors, process_manager)

            unless dispatched_message.blank?
              raise dispatched_message.inspect
              processing_errors << dispatched_message
              break
            end
          end  
        end

        unless processing_errors.blank?
          MessageMailer.error_notification(processing_errors.inspect).deliver
        end

        unless creation_errors.blank?
          MessageMailer.error_notification(creation_errors.join("\n")).deliver
        end

        process_manager.delete_pid_file
      else
        error_message = process_manager.relevant_existing_process_info
        MessageMailer.error_notification(error_message).deliver
      end
    end
  end

  def self.lock_file_content(messages)
    %Q{
        ACTION:'message.batch_send'
        PID:#{Process.pid}
        MESSAGE:'sending messages with ids #{messages.collect(&:id).join(', ')}'
        TIME:#{Time.now}
    }
  end

  def build_new_message_labels(identifiers)
    identifiers.each do |identifier|
      message_labels.build(label_id: identifier, shop_identifier: shop_id)
    end
  end

  def manipulate_existing_message_labels(identifiers)
    existing_labels = message_labels.reject(&:new_record?)
    existing_message_label_ids = existing_labels.collect(&:label_id)

    identifiers.each do |identifier|

      unless identifier.blank?
        index = existing_message_label_ids.index(identifier.to_i)
        unless index.blank?
          message_label = existing_labels[index]
          message_label.update_attributes!(message_id: id, label_id: identifier)
          existing_labels.delete_at(index)
          existing_message_label_ids.delete_at(index)
        else
          existing_label = MessageLabel.create!(label_id: identifier, message_id: id)
        end
      end

    end

    existing_labels.each(&:destroy)
    #reload
  end


  def canned_from
    #manager.email_like_from
    if shop.verified_email.present? && shop.ses_verified?
      %{"#{self.shop_name}" <#{shop.verified_email}>}  
    else
      %{"#{self.shop_name}" <#{shop.partner.from_email}>}
    end
  end

  def canned_subject
    if self.instance_of?(GeneralMessage)
      "{{Customer Name}}, we have an announcement."
    elsif self.instance_of?(CouponMessage)
      "{{Customer Name}}, here's a Coupon just for you."
    elsif self.instance_of?(EventMessage)
      "{{Customer Name}}, we are hosting a special event and you are invited."
    elsif self.instance_of?(ProductMessage)
      "{{Customer Name}}, check out our new product!"
    elsif self.instance_of?(SaleMessage)
      "We are having a sale! {{Customer Name}}, don't miss out."
    elsif self.instance_of?(SpecialMessage)
      "A special offer just for {{Customer Name}}."
    elsif self.instance_of?(SurveyMessage)
      "{{Customer Name}}, we need your feedback!"
    end
  end

  def fetch_labeled_users(ids)
    UserLabel.fetch_user_count(ids)
  end

  def validate_beginning
    validate_date_time('beginning', "date and time")
  end

  def validate_ending
    validate_date_time('ending', "date and time")
  end

  def validate_date_time(attr_name, attr_name_message)
    if self.send(attr_name.to_sym).present?
      begin
        Date.parse(self.send(attr_name.to_sym).to_s)
      rescue
        errors.add(attr_name.to_s.to_sym, "#{attr_name} is invalid")
      end
    end
  end

  def validate_button_url
    if button_url.present? && !button_url.match(/^(https?:\/\/(w{3}\.)?)|(w{3}\.)|[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/i)
      self.errors.add(:button_url, "is invalid. Here is an example: http://example.com")   
      return
    end 

    if button_url.present? && message_image.blank? && button_text.blank?
      self.errors.add(:button_url, "You have added a link but there is no image uploaded or button pointing to it. Please add one.")
    end
  end

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end

  def assign_coupon_code
    if self.partner.eatstreet? && self.coupon_code.blank?
      self.coupon_code = Devise.friendly_token.first(12)
    end
  end

  # Greeting is assigned only to the existing messages
  def assign_greeting
    self.greeting = generate_greeting
  end

  def remove_greeting
    self.greeting = nil
  end

  def fetch_receiver_ids    
    if Rails.env.staging? && partner.eatstreet?
      ids = User.where(email: 'ian@eatstreet.com').pluck(:id) 
      ids += User.where(email: 'gaurav+eatstreet@optyn.com').pluck(:id)
      ids += User.where(email: 'alen@optyn.com').pluck(:id)
      return ids
    end

    return all_active_user_ids if label_select_all?(self.label_ids)

    receiver_label_user_ids = label_user_ids
    Connection.for_users(receiver_label_user_ids).distinct_receiver_ids.for_shop(self.shop.id).active.collect(&:user_id).uniq
  end

  def replenish_draft_count
    Message.cached_drafts_count(shop, true)
  end

  def replenish_draft_and_queued_count
    Message.cached_drafts_count(shop, true)
    Message.cached_queued_count(shop, true)
    Message.cached_approves_count(shop, true)
  end

  def send_on_greater_by_hour
    self.errors.add(:send_on, "should be more than an hour") if self.send_on.present? && !(self.shop.virtual) && !(self.send_on > 1.hour.since)
  end

  def validate_child_message
    if self.first_response_child.present? && !(self.first_response_child.valid?)
      self.errors.add(:child_message, "Response message is yet to be completed")
    end
  end

  def validate_discount_amount
    return self.errors.add(:discount_amount, "Please add the discount amount") if discount_amount.blank?
    numeric_amount = discount_amount.to_i

    if percentage_off?
      self.errors.add(:discount_amount, "Please add valid values between 0 - 100") if numeric_amount <= 0 || numeric_amount > 100
    else
      self.errors.add(:discount_amount, "Please make sure you add a numeric value") if numeric_amount <= 0
    end
  end

  def transfer_child_state
    if self.instance_of?(SurveyMessage)
      if self.first_response_child.present?
        first_response_child.update_attribute(:state, self.state)
      end
    end
  end

  def assign_parent_state_if
    if self.parent_id.present?
      self.update_attribute(:state, self.parent.state)
    end
  end

  def shop_virtual?
    self.manager.present? && self.shop.present? && self.shop.virtual
  end

  def validate_recipient_count
    receiver_count = label_select_all?(self.label_ids) ? all_active_user_ids.size : label_ids.size
    self.errors.add(:label_ids, "No receivers for this campaign. Please select your labels appropriately or import your email list.") if receiver_count <= 0
  end

  def label_user_ids
    labels.collect(&:user_labels).flatten.collect(&:user_id)
  end

  def label_select_all?(labels_ids_for_message)
    labels_for_message = Label.where(id: label_ids)
    labels_for_message.size == 1 && labels_for_message.first.inactive?
  end

  def all_active_user_ids
    shop.connections.active.collect(&:user_id) 
  end  

  def replace_customer_name(receiver, article, preview)
    user_name = "#{(receiver.first_name.titleize rescue nil)}" if receiver.present?
    if user_name.present?
      article.gsub(/{{Customer Name}}/i, user_name)
    elsif !preview
      # replace the occurrece in greeting      
      regex = /{{Customer Name}},/i #regex when the customer name is missing /eom
      personalized_article = (article.to_s.gsub(regex, "")).strip
      
      # replace rest of the occurrences
      regex = /{{Customer Name}}/i #regex when the customer name is missing /eom
      personalized_article = (personalized_article.to_s.gsub(regex, "")).strip #incase customer name is used somewhere else.

      personalized_article[0] = personalized_article.to_s.first.capitalize[0] if personalized_article.present?
      personalized_article
    else
      article
    end
  end

  def clear_cached_template
    self.template.delete_cached_content(self.uuid) if self.template_id.present?
  end
end
