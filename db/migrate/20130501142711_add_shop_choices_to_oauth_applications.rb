class AddShopChoicesToOauthApplications < ActiveRecord::Migration
  def change
    add_column(:oauth_applications, :embed_code, :text)
    add_column(:oauth_applications, :button_size, :integer, default: 1)
    add_column(:oauth_applications, :checkmark_icon, :boolean, default: true)
    add_column(:oauth_applications, :show_default_optyn_text, :boolean, default: true)
    add_column(:oauth_applications, :custom_text, :text)
  end
end
