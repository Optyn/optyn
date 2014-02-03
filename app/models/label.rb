class Label < ActiveRecord::Base
  belongs_to :shop
  belongs_to :survey_answer
  
  has_many :user_labels, dependent: :destroy
  has_many :message_labels, dependent: :destroy

  attr_accessible :shop_id, :name, :survey_answer_id

  scope :active, where(active: true)
  
  scope :inactive, where(active: false)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :right_join_user_labels, joins("RIGHT JOIN user_labels ON labels.id = user_labels.label_id")

  scope :group_on_id, group("labels.id")

  SELECT_ALL_NAME = 'Select All'

  def self.labels_with_customers(shop_identifier)
    for_shop(shop_identifier).right_join_user_labels.group_on_id
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
end
