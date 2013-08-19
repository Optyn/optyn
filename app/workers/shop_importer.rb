class ShopImporter
  @queue = :import_queue

  def self.perform(payload_id)
    payload = ApiRequestPayload.find(payload_id)
    if payload.present?
      payload.update_attribute(:status, 'Inprocess')
      Shop.import(payload)
      payload.save
      payload.update_attributes(status: 'Processed')
      PartnerMailer.import_complete(payload).deliver
    end
  end
end