class AddRenderChoiceToOauthApplications < ActiveRecord::Migration
  def self.up
    remove_column :oauth_applications, :button_size
    add_column :oauth_applications, :render_choice, :integer, default: 2
  end

  def self.down
    add_column :oauth_applications, :button_size, :integer, default: 1
    remove_column :oauth_applications, :render_choice
  end
end
