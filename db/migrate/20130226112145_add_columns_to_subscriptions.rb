class AddColumnsToSubscriptions < ActiveRecord::Migration
  def up
    add_column :subscriptions, :shop_id, :integer
    add_column :subscriptions, :active, :boolean
  end

  def down 
    remove_column :subscriptions, :shop_id
    remove_column :subscriptions, :active
  end
end
