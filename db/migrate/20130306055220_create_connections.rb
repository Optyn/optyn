class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
    	t.references :user
    	t.references :shop
    	t.boolean :active, default: true 

      t.timestamps
    end

    add_index(:connections, [:shop_id, :user_id], :unique => true)
  end
end
