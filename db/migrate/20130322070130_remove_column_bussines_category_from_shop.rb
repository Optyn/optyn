class RemoveColumnBussinesCategoryFromShop < ActiveRecord::Migration
  def up
  end

  def down
  	remove_column :shops, :business_category
  end
end
