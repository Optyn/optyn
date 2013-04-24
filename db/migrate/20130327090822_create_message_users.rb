class CreateMessageUsers < ActiveRecord::Migration
  def change
    create_table :message_users do |t|
      t.references  :message
      t.references  :user
      t.references  :message_folder
      t.boolean  :is_read,             :default => false
      t.boolean  :email_read,          :default => false
      t.boolean  :is_forwarded,        :default => false
      t.datetime :received_at
      t.boolean  :added_individually,  :default => false
      t.string :uuid

      t.timestamps
    end

    add_index :message_users, [:message_id, :added_individually]
    add_index :message_users, [:message_id, :user_id]
    add_index :message_users, [:user_id, :message_folder_id]
    add_index :message_users, :uuid, unique: true
  end
end
