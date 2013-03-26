class Label < ActiveRecord::Base
  belongs_to :shop
  has_many :user_labels, dependent: :destroy

  attr_accessible :shop_id, :name
end
