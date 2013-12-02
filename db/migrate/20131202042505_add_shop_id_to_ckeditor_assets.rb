class AddShopIdToCkeditorAssets < ActiveRecord::Migration
  def change
    add_column :ckeditor_assets, :shop_id, :integer
    add_index :ckeditor_assets, :shop_id
  end
end
