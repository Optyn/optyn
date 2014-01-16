class MarketingAgenciesController < ApplicationController
  layout "application"
  def new
    @marketing_agency_inquiry = MarketingAgencyInquiry.new
  end
  
  def create
    @marketing_agency_inquiry = MarketingAgencyInquiry.new(params[:marketing_agency_inquiry])
    @marketing_agency_inquiry.save!
    MarketingAgencySender.perform_async(@marketing_agency_inquiry.id)
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    render partial: 'form', status: :unprocessable_entity
  end

end
