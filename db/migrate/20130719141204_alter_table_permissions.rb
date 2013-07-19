class AlterTablePermissions < ActiveRecord::Migration
  def up
  	rename_column(:permissions, :name, :permission_name)
    permission = Permission.find_by_permission_name('name')
    unless permission
	    permission.permission_name = 'fullname'
	    permission.save
    end
  end

  def down
  	rename_column(:permissions, :permission_name, :name)
  end
end
