class DropVirtualConnectionsTable < ActiveRecord::Migration
  def up
    drop_table :virtual_connections
  end

  def down
    #Irrevesebile migration
  end
end
