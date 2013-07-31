class AddUuidToLocations < ActiveRecord::Migration
  def change
    add_column(:locations, :uuid, :string)
    add_index(:locations, :uuid, unique: true)
  end
end
