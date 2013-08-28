class ShopImporter
  @queue = :import_queue

  def self.perform(payload_id)
    payload = ApiRequestPayload.find(payload_id)
    begin
      if payload.present?
        payload.update_attribute(:status, 'Inprocess')
        counters, output, unparsed = Shop.import(payload)
        payload.stats = counters
        payload.save
        payload.update_attributes(status: 'Processed')
        PartnerMailer.import_complete(payload, output, unparsed).deliver
      end
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      PartnerMailer.import_error(payload, e.message).deliver
      payload.update_attributes(status: 'Error')
    end
  end
end