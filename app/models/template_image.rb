class TemplateImage < ActiveRecord::Base

  belongs_to :template

  attr_accessible :template_id, :title, :parent_id, :image, :size, :width, :height, :remote_image_url, :remove_image

  mount_uploader :image, TemplateImageUploader

  validates :image, presence: true
  validates :image, file_size: {maximum: 10.megabytes.to_i}, :if => :should_validate?

  def image_location
    image_url
  end

  private
  def should_validate?
    image.present?
  end
end
