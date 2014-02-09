class MarketingAgencyInquiry < ActiveRecord::Base
  attr_accessible :name, :email, :company_name, :phone_number

  validates :name, presence: true
  validates :email, :presence => true, :email => true
  

  validates :phone_number, length: {maximum: 20}
  validates :phone_number, :phony_plausible => true

end
