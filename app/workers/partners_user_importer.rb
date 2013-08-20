class PartnersUserImporter
	@queue = :import_queue

  def self.perform(payload_id)
    begin
      payload = ApiRequestPayload.find(payload_id)
      content = User.download_file_from_payload(payload)
      statistics, output, unparsed = User.import(content, payload.manager, payload.label)
      puts ("-" * 25) + "OUTPUT" + ("-" * 25)
      puts "Statistics: #{statistics.inspect}"
      puts "Unparsed: #{unparsed}"
      puts "Output: #{output}"
      puts "-" * 56
      payload.stats = statistics
      payload.stats = [payload.stats] if payload.stats.is_a?(Hash)
      payload.save
    rescue => e
      puts e.message
      puts e.backtrace
    end
    payload.update_attributes(status: 'Processed')
    MerchantMailer.import_stats(payload, output, unparsed).deliver
  end
end