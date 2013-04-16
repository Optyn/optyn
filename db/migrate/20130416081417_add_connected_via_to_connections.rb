class AddConnectedViaToConnections < ActiveRecord::Migration
  def change
    add_column(:connections, :connected_via, :string)
  end
end
