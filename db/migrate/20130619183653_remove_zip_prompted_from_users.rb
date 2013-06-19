class RemoveZipPromptedFromUsers < ActiveRecord::Migration
  def up
    remove_column(:users, :zip_prompted)
  end

  def down
    add_column(:users, :zip_prompted, :boolean)
  end
end
