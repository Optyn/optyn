class MessageImage < ActiveRecord::Base
  belongs_to :message

  attr_accessor :image_width

  attr_accessible :message_id, :title, :parent_id, :image, :size, :width, :height, :remote_image_url, :remove_image, :image_width

  mount_uploader :image, MessageImageUploader

  validates :image, presence: true
  validates :image, file_size: {maximum: 10.megabytes.to_i}, :if => :should_validate?

  before_save :resize_and_store_geometry


  def image_location
    image_url
  end

  private
  def should_validate?
    image.present?
  end

  def resize_and_store_geometry
    image.rearrange_dimensions
    image.store_geometry
  end
end