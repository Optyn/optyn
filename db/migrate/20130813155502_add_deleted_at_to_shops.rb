class AddDeletedAtToShops < ActiveRecord::Migration
  def change
  	add_column(:shops, :deleted_at, :datetime)
  end
end
