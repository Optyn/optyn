class AddWidthAndHeightToTemplateImages < ActiveRecord::Migration
  def change
    add_column(:template_images, :width, :integer)
    add_column(:template_images, :height, :integer)
  end
end
