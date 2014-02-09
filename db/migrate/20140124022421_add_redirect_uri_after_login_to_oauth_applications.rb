class AddRedirectUriAfterLoginToOauthApplications < ActiveRecord::Migration
  def change
    add_column(:oauth_applications, :redirect_uri_after_login, :string)
  end
end
