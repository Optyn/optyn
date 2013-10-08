class AddFooterBackgroundColorToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :footer_background_color, :string, default: "#ffffff")
  end
end
