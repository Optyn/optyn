class AddWebsiteAndIdentifierAndTimezoneToShops < ActiveRecord::Migration
  def change
    add_column :shops, :website, :string
    add_column :shops, :identifier, :string
    add_column :shops, :time_zone, :string

    add_index(:shops, :identifier, unique: true)
  end
end
