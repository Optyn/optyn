class AddColumnDescriptionToShops < ActiveRecord::Migration
  def change
  	add_column :shops, :description, :string
  	add_column :shops, :logo_img, :string
  	add_column :shops, :business_category, :string
  end
end
