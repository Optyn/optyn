class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code

  validates :content, presence: true
  validate :validate_beginning
  validates :type_of_discount, presence: true
  validates :discount_amount, presence: true
end