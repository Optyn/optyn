class PartnerInquirySender
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue
  # @queue = :general_queue

  def perform(inquiry_id)
    GenericMailer.announce_partner_inquiry(inquiry_id).deliver
  end
end
