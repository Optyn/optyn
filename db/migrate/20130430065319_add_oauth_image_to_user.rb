class AddOauthImageToUser < ActiveRecord::Migration
  def change
    add_column :managers, :oauth_image, :string
    add_column :users, :oauth_image, :string
  end
end
