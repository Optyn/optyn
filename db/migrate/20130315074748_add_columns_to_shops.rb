class AddColumnsToShops < ActiveRecord::Migration
  def change
  	add_column :shops, :business_category, :string
  end
end
