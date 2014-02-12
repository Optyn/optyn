class Label < ActiveRecord::Base
  belongs_to :shop
  belongs_to :survey_answer
  
  has_many :user_labels #, dependent: :delete
  has_many :message_labels #, dependent: :delete

  before_destroy :bulk_delete_user_lables, :bulk_delete_message_labels

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

  private
    def bulk_delete_user_lables
      UserLabel.where(label_id: self.id).delete_all
    end

    def bulk_delete_message_labels
      MessageLabel.where(id: self.id).delete_all
    end
end
