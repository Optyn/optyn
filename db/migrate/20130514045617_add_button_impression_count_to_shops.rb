class AddButtonImpressionCountToShops < ActiveRecord::Migration
  def change
    add_column :shops, :button_impression_count, :integer
  end
end
