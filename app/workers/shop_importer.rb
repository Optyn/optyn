class ShopImporter
  include Sidekiq::Worker
  @queue = :import_queue

  def perform(payload_id)
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
      payload.update_attributes(status: 'Error')
      PartnerMailer.import_error(payload, e.message).deliver
    end
  end
end