class UserImporter
  @queue = :users_import_queue

  def self.perform(file_import_id)
    FileImport.create_connections()
  end
end