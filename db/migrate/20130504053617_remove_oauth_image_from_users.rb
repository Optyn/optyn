class RemoveOauthImageFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :oauth_image
  end

  def down
    add_column :users, :oauth_image, :string
  end
end
