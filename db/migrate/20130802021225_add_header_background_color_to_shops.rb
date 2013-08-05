class AddHeaderBackgroundColorToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :header_background_color, :string, default: "#1791C0")
  end
end
