class ShopImporter
  @queue = :import_queue

  def self.perform(payload_id)
    payload = ApiRequestPayload.find(payload_id)
    if payload.present?
      payload.update_attribute(:status, 'Inprocess')
      params = payload.body
      param_shops = params['shops']
      Shop.import(param_shops, payload)
      payload.update_attributes(body: nil, status: 'Processed')
    end
  end
end