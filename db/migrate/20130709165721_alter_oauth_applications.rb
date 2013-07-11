class AlterOauthApplications < ActiveRecord::Migration
  def up
    add_column :oauth_applications, :call_to_action, :integer, default: 2
  end

  def down
    remove_column :oauth_applications, :call_to_action
  end
end
