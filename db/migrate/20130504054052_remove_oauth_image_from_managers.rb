class RemoveOauthImageFromManagers < ActiveRecord::Migration
  def up
    remove_column :managers, :oauth_image
  end

  def down
    add_column :managers, :oauth_image, :string
  end
end
