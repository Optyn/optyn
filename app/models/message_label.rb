class MessageLabel < ActiveRecord::Base
  belongs_to :message
  belongs_to :label

  attr_accessible :label_id, :message_id, :shop_identifier

  attr_accessor :shop_identifier

  validate :label_id, presence: true
  validate :message_id, presence: true
  validate :appropriate_assignment

  private
  def appropriate_assignment
  	message_shop_id = message.shop_id rescue shop_identifier
  	label_shop_id = label.shop_id rescue nil
  	self.errors.add(:base, "Invalid label assigned") if message_shop_id != label_shop_id
  end
end