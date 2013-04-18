class Message < ActiveRecord::Base
  belongs_to :manager
  has_many :message_labels, dependent: :destroy
  has_many :labels, through: :message_labels

  attr_accessible :label_ids, :name, :second_name, :send_immediately

  FIELD_TEMPLATE_TYPES = ["coupon_message", "event_message", "general_message", "product_message", "sale_message", "special_message", "survey_message"]
  DEFAULT_FIELD_TEMPLATE_TYPE = "general_message"
  COUPON_FIELD_TEMPLATE_TYPE = "coupon_message"
  EVENT_FIELD_TEMPLATE_TYPE = "event_message"
  PRODUCT_FIELD_TEMPLATE_TYPE = "product_message"
  SALE_FIELD_TEMPLATE_TYPE = "sale_message"
  SPECIAL_FIELD_TEMPLATE_TYPE = "special_message"
  SURVEY_FIELD_TEMPLATE_TYPE = "survey_message"
  PER_PAGE = 50
  PAGE = 1

  before_create :assign_uuid

  validates :name, presence: true
  validates :second_name, presence: true

  scope :for_state_and_sender, ->(state_name, manager_identifier) { with_state(state_name).where(manager_id: manager_identifier) }

  scope :for_uuids, ->(uuids) { where(uuid: uuids) }

  state_machine :state, :initial => :draft do

    event :save_draft do
      transition :draft => same
    end

    event :preview do
      transition :draft => same
    end

    event :launch do
      transition :draft => :queued
    end

    event :move_to_trash do
      transition [:draft, :queued, :sent] => :trash
    end

    event :move_to_draft do
      transition [:queued, :trash] => :draft
    end

    event :discard do
      transition :trash => :delete
    end

    event :start_transit do
      transition :queued => :transit
    end

    event :deliver do
      transition [:queued, :transit] => :sent
    end

    before_transition :draft => same do |message|
      message.subject = message.send(:canned_subject)
      message.from = message.send(:canned_from)
    end

    before_transition :draft => :queued do |message|
      message.valid?
    end

    before_transition :draft => :queued do |message|
      message.send_on = Time.parse(Date.today.to_s + " 7:30 AM CST")
    end


    state :draft do
      def save(options={})
        super(validate: false)
      end
    end
  end

  def self.fetch_template_name(params_type)
    FIELD_TEMPLATE_TYPES.include?(params_type.to_s) ? params_type : DEFAULT_FIELD_TEMPLATE_TYPE
  end

  def self.paginated_drafts(manager, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_sender(:draft, manager.id).page(page_number).per(per_page)
  end

  def self.cached_drafts_count(manager, force=false)
    cache_key = "draft-count-manager-#{manager.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.message_folder) do
      for_state_and_sender(:draft, manager.id).count
    end
  end

  def self.paginated_trash(manager, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_sender(:trash, manager.id).page(page_number).per(per_page)
  end

  def self.paginated_sent(manager, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_sender(:sent, manager.id).page(page_number).per(per_page)
  end

  def self.paginated_queued(manager, page_number=PAGE, per_page=PER_PAGE)
    for_state_and_sender(:queued, manager.id).page(page_number).per(per_page)
  end

  def self.cached_queued_count(manager, force=false)
    cache_key = "queued-count-manager-#{manager.id}"
    Rails.cache.fetch(cache_key, :force => force, :expires_in => SiteConfig.ttls.message_folder) do
      for_state_and_sender(:queued, manager.id).count
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

  def label_ids(labels=[])
    label_identifiers = message_labels.pluck(:label_id)
    if label_identifiers.blank?
      label_identifiers = shop.inactive_label.id
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
    ids = self.label_ids

    if 1 == ids.size
      label = Label.find(ids.first)

      if label.inactive?
        return shop.users.count
      end
    end

    fetch_labeled_users(ids)
  end

  def in_preview_mode?(preview=true)
    preview || draft?
  end

  def shop_name
    shop.name
  end

  def sanitized_discount_amount
    discount_amount.gsub(/[^A-Za-z0-9]/, "")
  end

  def percentage_off?
    discount_type = type_of_discount.to_s.to_sym
    :dollar_off == discount_type
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

  def build_new_message_labels(identifiers)
    identifiers.each do |identifier|
      message_labels.build(label_id: identifier)
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


  def shop
    manager.shop
  end

  def canned_from
    manager.email_like_from
  end

  def canned_subject
    if self.instance_of?(GeneralMessage)
      "#{shop.name}, wants to make sure you hear the latest.."
    elsif self.instance_of?(CouponMessage)
      "{{Customer Name}}, Here's a Coupon for #{shop.name}!"
    elsif self.instance_of?(EventMessage)
      "#{shop.name} invites you to an event!"
    elsif self.instance_of?(ProductMessage)
      "#{shop.name} is introducing a New Product you'll want to have"
    elsif self.instance_of?(SaleMessage)
      "#{shop.name} is having a sale! Don't miss out."
    elsif self.instance_of?(SpecialMessage)
      "A special offer just for you {{Customer Name}}, Courtesy of #{shop.name}."
    elsif self.instance_of?(SurveyMessage)
      "#{shop.name} would like your feedback!"
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
    unless self.send(attr_name.to_sym).blank?
      begin
        Date.parse(self.send(attr_name.to_sym))
      rescue
        errors.add(:base, "#{attr_name_message} is an invalid date")
      end
    end
  end

  def assign_uuid
    self.uuid = UUIDTools::UUID.random_create.to_s.gsub(/[-]/, "")
  end
end
