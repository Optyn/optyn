class RewriteEmailIndexOnUsers < ActiveRecord::Migration
  def up
    remove_index(:users, :email) rescue nil
    add_index(:users, :email, unique: true)
  end

  def down
    remove_index(:users, :email)
  end
end
