class AlterTablePermissions < ActiveRecord::Migration
  def up
  	rename_column(:permissions, :name, :permission_name)
  end

  def down
  	rename_column(:permissions, :permission_name, :name)
  end
end
