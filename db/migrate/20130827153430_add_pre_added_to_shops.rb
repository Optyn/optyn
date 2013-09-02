class AddPreAddedToShops < ActiveRecord::Migration
  def change
  	add_column(:shops, :pre_added, :boolean, default: false)
  end
end
