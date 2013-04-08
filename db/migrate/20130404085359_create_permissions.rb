class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
    	t.boolean :vis_name
    	t.boolean :vis_email
    	t.references :user
      t.timestamps
    end
  end
end
