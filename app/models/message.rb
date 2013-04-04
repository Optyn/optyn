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

  validates :name, presence: true
  validates :second_name, presence: true

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

    #event :start_transit do
    #  transition :queued => :transit
    #end
    #
    #event :deliver do
    #  transition [:queued, :transit] => :sent
    #end

    before_transition :draft => same do |message|
      message.subject = message.send(:canned_subject)
      message.from = message.send(:canned_from)
    end

    state :draft do
      def save
        super(validate: false)
      end
    end
  end

  def self.fetch_template_name(params_type)
    FIELD_TEMPLATE_TYPES.include?(params_type.to_s) ? params_type : DEFAULT_FIELD_TEMPLATE_TYPE
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
    labels.message_labels(self).collect(&:name)
  end


  private
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
    reload
  end


  def shop
    manager.shop
  end

  def canned_from
    manager.email_like_from
  end

  def canned_subject
    if self.instance_of?(GeneralMessage)
      "General Announcement"
    elsif self.instance_of?(CouponMessage)
      "Coupon Message"
    elsif self.instance_of?(EventMessage)
      "Event Message"
    elsif self.instance_of?(ProductMessage)
      "Product Announcement"
    elsif self.instance_of?(SpecialMessage)
      "Special Announcement"
    elsif self.instance_of?(SurveyMessage)
      "Survey Message"
    end
  end
end
