class AddWidthAndHeightToMessageImages < ActiveRecord::Migration
  def change
    add_column(:message_images, :width, :integer)
    add_column(:message_images, :height, :integer)
  end
end
