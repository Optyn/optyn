class PartnerInquirySender
 @queue = :general_queue

  def self.perform(inquiry_id)
    GenericMailer.announce_partner_inquiry(inquiry_id).deliver
  end
end
