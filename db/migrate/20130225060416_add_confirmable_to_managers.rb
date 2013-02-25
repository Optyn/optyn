class AddConfirmableToManagers < ActiveRecord::Migration

  def self.up
    add_column :managers,:confirmation_token,:string   
    add_column :managers,:confirmed_at, :datetime 
    add_column :managers, :confirmation_sent_at, :datetime 
    add_column :managers, :unconfirmed_email, :string   
    add_index :managers, :confirmation_token, :unique => true
  end

  def self.down
    remove_column :managers, :confirmation_token
    remove_column :managers, :confirmed_at
    remove_column :managers, :confirmation_sent_at
    remove_column :managers, :unconfirmed_email
  end


end
