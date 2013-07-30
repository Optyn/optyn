class AddIdentifierToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :uuid, :string)
    add_index(:shops, :uuid, unique: true)
  end
end
