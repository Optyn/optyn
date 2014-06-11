class AddIndicesToConnectionsLabelsAndUserLabels < ActiveRecord::Migration
  def change
  	add_index :connections, [:active, :shop_id, :user_id], :name => 'index_connections_on_active_and_shop_id_and_user_id'
  	add_index :labels, [:active], :name => 'index_labels_on_active'
  	add_index :user_labels, [:user_id], :name => 'index_user_labels_on_user_id'
  end
end
