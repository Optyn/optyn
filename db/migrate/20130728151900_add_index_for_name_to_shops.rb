class AddIndexForNameToShops < ActiveRecord::Migration
  def change
    add_index(:shops, :name, unique: true)
  end
end
