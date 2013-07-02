class CreateVirtualConnections < ActiveRecord::Migration
  def change
    create_table :virtual_connections do |t|
      t.references :shop
      t.references :user
      t.text :html_content
      t.string :state

      t.timestamps
    end

    add_index(:virtual_connections, [:shop_id, :user_id])
  end
end
