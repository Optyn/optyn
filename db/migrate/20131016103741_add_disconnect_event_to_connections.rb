class AddDisconnectEventToConnections < ActiveRecord::Migration
  def change
    add_column(:connections, :disconnect_event, :string)
  end
end
