class AddUploadLocationToShops < ActiveRecord::Migration
  def change
  	add_column(:shops, :upload_location, :string, limit: 1000)
  end
end
