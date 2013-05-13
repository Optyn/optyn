class UserImporter
  @queue = :users_import_queue

  def self.perform(file_import_id)
    file_import = FileImport.find(file_import_id)
    file_import.assign_being_parsed_status
    file_import.create_connections
  end
end