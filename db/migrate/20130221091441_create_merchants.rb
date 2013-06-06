class CreateMerchants < ActiveRecord::Migration
  def up
    remove_index :authentications, :column => [:uid, :provider]
    remove_index :authentications, :column => :user_id
    remove_column :authentications,:user_id

    create_table :merchants do |t|
      t.string :name
      t.timestamps
    end
  end
  def down 
   drop_table :merchants 
  end
end
