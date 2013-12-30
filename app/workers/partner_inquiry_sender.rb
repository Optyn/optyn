class PartnerInquirySender
  include Sidekiq::Worker
  @queue = :general_queue

  def perform(inquiry_id)
    GenericMailer.announce_partner_inquiry(inquiry_id).deliver
  end
end
