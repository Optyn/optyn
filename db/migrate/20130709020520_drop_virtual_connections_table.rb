class DropVirtualConnectionsTable < ActiveRecord::Migration
  def up
    drop_table :virtual_connections if ActiveRecord::Base.connection.table_exists?('virtual_connections')
  end

  def down
    #Irrevesebile migration
  end
end
