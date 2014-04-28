class AddShowFormToOauthApplications < ActiveRecord::Migration
  def change
     add_column(:oauth_applications, :show_form, :boolean, :default => false)
  end
end
