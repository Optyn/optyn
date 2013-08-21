class MessageImage < ActiveRecord::Base
  belongs_to :message

  attr_accessible :message_id, :title, :parent_id, :image, :size, :width, :height, :remote_image_url

  mount_uploader :image, MessageImageUploader

  validates :image, presence: true
  validates :image, file_size: {maximum: 10.megabytes.to_i}, :if => :should_validate?

  private
  def should_validate?
    image.present?
  end
end