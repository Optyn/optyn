class AddVirtualFlagToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :virtual, :boolean, default: false)
  end
end
