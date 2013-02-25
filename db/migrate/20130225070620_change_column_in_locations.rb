class ChangeColumnInLocations < ActiveRecord::Migration
  def up
    rename_column(:locations, :merchant_id, :shop_id)

  end

  def down
  end
end
