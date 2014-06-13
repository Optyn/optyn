class SpecialMessage < Message
  attr_accessible :content, :type_of_discount, :discount_amount, :ending, :fine_print, :coupon_code,
  				  :permanent_coupon
  before_save :assign_coupon_code

  validates :content, presence: true
  validates :type_of_discount, presence: true, if: :partner_eatstreet?
  validate :validate_discount_amount, if: :partner_eatstreet?
  validate :validate_ending
end