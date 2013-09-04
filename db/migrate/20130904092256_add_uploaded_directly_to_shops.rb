class AddUploadedDirectlyToShops < ActiveRecord::Migration
  def change
  	add_column(:shops, :uploaded_directly, :boolean, default: false)
  end
end
