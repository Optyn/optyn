class VirtualConnectionToRealConnector
  @queue = :virtual_connection_queue

  def self.perform(virtual_connection_id)
    virtual_connection = VirtualConnection.find_by_id(virtual_connection_id)
    virtual_connection.create_real_connection
  end
end