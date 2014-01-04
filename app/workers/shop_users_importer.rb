class ShopUsersImporter
  include Sidekiq::Worker
  sidekiq_options :queue => :import_queue
  ##Defination: Imports Merchants
  # @queue = :import_queue

  def perform(payload_id)
    payload = ApiRequestPayload.find(payload_id)
    # binding.pry
    begin
      if payload.present?
        payload.update_attribute(:status, 'Inprocess')
        counters, output, unparsed = User.user_import(payload)
        payload.stats = counters
        payload.save
        payload.update_attributes(status: 'Processed')
        ShopUserMailer.import_complete(payload, output, unparsed).deliver
      end
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      payload.update_attributes(status: 'Error')
      ShopUserMailer.import_error(payload, e.message).deliver
    end
  end
end