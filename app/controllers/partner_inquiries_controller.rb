class PartnerInquiriesController < ApplicationController
  def new
    @partner_inquiry = PartnerInquiry.new
  end

  def create
    @partner_inquiry = PartnerInquiry.new(params[:partner_inquiry])
    @partner_inquiry.save!
    flash[:notice] = "Inquiry submitted successfully. We will be in touch within 24 hours or less"
    Resque.enqueue(PartnerInquirySender, @partner_inquiry.id)
    redirect_to  new_partner_inquiry_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "Could not submit the inquiry form"
    render action: :new
  end
end
