class RemoveFieldsFromShops < ActiveRecord::Migration
  def up
  	remove_column :shops, :uploaded_directly
  	remove_column :shops, :upload_location
  end

  def down
  	add_column :shops, :uploaded_directly, :boolean
  	add_column :shops, :upload_location, :string
  end
end
