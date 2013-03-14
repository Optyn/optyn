class AddColumnToShops < ActiveRecord::Migration
  def change
  	add_column :shops, :description, :string
  	add_column :shops, :logo_img, :string
  end
end
