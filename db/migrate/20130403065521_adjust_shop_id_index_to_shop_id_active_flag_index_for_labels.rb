class AdjustShopIdIndexToShopIdActiveFlagIndexForLabels < ActiveRecord::Migration
  def up
    remove_index(:labels, :shop_id)
    add_index(:labels, [:shop_id, :active])
  end

  def down
    add_index(:labels, :shop_id)
    remove_index(:labels, [:shop_id, :active])
  end
end
