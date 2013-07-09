class AddAliasToUsers < ActiveRecord::Migration
  def change
    add_column :users, :alias, :string
    add_index :users, :alias, unique: true
  end
end
