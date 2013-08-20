class PartnersUserImporter
	@queue = :import_queue

  def self.perform(payload_id)
    begin
    payload = ApiRequestPayload.find(payload_id)
    content = User.download_file_from_payload(payload)
    payload.stats = User.import(content, payload.manager, payload.label)
    payload.stats = [payload.stats] if payload.stats.is_a?(Hash)
    payload.save
rescue => e
  puts "*" * 100
  puts e.message
  puts e.backtrace
end
    payload.update_attributes(status: 'Processed')
    MerchantMailer.import_stats(payload).deliver
  end
end