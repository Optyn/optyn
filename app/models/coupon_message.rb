class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  before_save :assign_coupon_code

  validate :validate_ending
  validates :type_of_discount, presence: true
  validate :validate_discount_amount
  validates :content, presence: true
  validate :validate_ending
end