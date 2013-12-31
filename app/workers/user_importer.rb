class UserImporter
  include Sidekiq::Worker
	##Defination: Imports User By Merchant

  @queue = :import_queue

  def perform(file_import_id)
  	# binding.pry
    file_import = FileImport.find(file_import_id)
    file_import.assign_being_parsed_status
    file_import.create_connections
  end
end