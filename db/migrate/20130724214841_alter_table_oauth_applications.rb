class AlterTableOauthApplications < ActiveRecord::Migration
  def up
    add_column(:oauth_applications, :begin_state, :integer, default: 1)
    add_column(:oauth_applications, :background_color, :string, default: '#046D95')
  end

  def down
    remove_column(:oauth_applications, :begin_state)
    remove_column(:oauth_applications, :background_color)
  end
end
