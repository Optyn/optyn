class Label < ActiveRecord::Base
  belongs_to :shop
  has_many :user_labels, dependent: :destroy
  has_many :message_labels, dependent: :destroy

  attr_accessible :shop_id, :name

  scope :active, where(active: true)
  scope :inactive, where(active: false)

  SELECT_ALL_NAME = 'Select All'

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
