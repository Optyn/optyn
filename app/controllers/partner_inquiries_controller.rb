class PartnerInquiriesController < ApplicationController
  def new
    @partner_inquiry = PartnerInquiry.new
  end

  def create
    @partner_inquiry = PartnerInquiry.new(params[:partner_inquiry])
    @partner_inquiry.save!
    PartnerInquirySender.perform_async(@partner_inquiry.id)
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    render partial: 'form', status: :unprocessable_entity
  end
end
