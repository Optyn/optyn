class Label < ActiveRecord::Base
  belongs_to :shop
  has_many :user_labels, dependent: :destroy
  has_many :message_labels, dependent: :destroy

  attr_accessible :shop_id, :name

  default_scope where(active: true)

  SELECT_ALL_NAME = 'Select All'

  def self.active_and_inactive(shop)
    with_exclusive_scope { shop.labels.all }
  end

  def self.inactive(shop)
    with_exclusive_scope { shop.labels.where(active: false) }
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
