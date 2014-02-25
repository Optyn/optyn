class AddVerifiedEmailAndSesVerifiedToShop < ActiveRecord::Migration
  def up
  	add_column :shops, :verified_email, :string
  	add_column :shops, :ses_verified, :boolean, default: false
  end

  def down
  	remove_column :shops, :verified_email
  	remove_column :shops, :ses_verified

  end
end
