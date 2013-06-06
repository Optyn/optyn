class CreatePermissionsUsers < ActiveRecord::Migration
  def change
    create_table :permissions_users do |t|
      t.references :permission
      t.references :user
      t.boolean :action
  		t.timestamps
  	end
    add_index :permissions_users, [:permission_id, :user_id]
  end
end
