class MarketingAgencySender
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true
  # @queue = :general_queue

  def perform(inquiry_id)
    GenericMailer.announce_marketing_agency_inquiry(inquiry_id).deliver
  end
end
