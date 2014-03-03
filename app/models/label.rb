class Label < ActiveRecord::Base
  belongs_to :shop
  belongs_to :survey_answer
  
  has_many :user_labels #, dependent: :delete
  has_many :message_labels #, dependent: :delete

  attr_accessible :shop_id, :name, :survey_answer_id

  SELECT_ALL_NAME = 'Select All'

  validates :name, :presence => true
  validates_uniqueness_of :name, :scope => [:shop_id]


  scope :active, where(active: true)
  
  scope :inactive, where(active: false)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :right_join_user_labels, joins("RIGHT JOIN user_labels ON labels.id = user_labels.label_id")

  scope :group_on_id, group("labels.id")

  scope :select_all_instance, ->(shop_identifier) { for_shop(shop_identifier).where(name: SELECT_ALL_NAME).inactive}

  def self.import_labels(shop_instance)
    active.all << defult_message_label(shop_instance)
  end

  def self.labels_with_customers(shop_identifier)
    for_shop(shop_identifier).right_join_user_labels.group_on_id
  end

  def self.defult_message_label(shop_instance)
    select_all_instance(shop_instance.id).first
  end

  def users_count
    user_labels.count
  end

  def inactive?
    !active
  end

  def select_all?
    inactive? && SELECT_ALL_NAME == name
  end

  def is_destroyable?
    linked_message_ids = self.message_labels.collect(&:message_id)
    has_queued_message = Message.where(id: linked_message_ids).pluck(:state).include? 'queued'
    !has_queued_message
  end

  private
    def bulk_delete_user_lables
      UserLabel.where(label_id: self.id).delete_all
    end

    def bulk_delete_message_labels
      MessageLabel.where(id: self.id).delete_all
    end
end
