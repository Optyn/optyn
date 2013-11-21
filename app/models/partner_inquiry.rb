class PartnerInquiry < ActiveRecord::Base
  attr_accessible :name, :email, :company_name, :phone_number, :merchants, :referrer, :comment

  validates :name, presence: true
  validates :email, :presence => true, :email => true
  validates :company_name, presence: true

  validates :phone_number, presence: true, length: {minimum: 10, maximum: 20}
  validates :phone_number, :phony_plausible => true

  MERCHANT_RANGES = ["0 - 1000", "1000 - 10000", "10000 - 25000", "25000 - 50000", "50000 and Above"]
  REFERRER_OPTIONS = ["Search", "Through my Network", "News / Media", "Other"]
end
