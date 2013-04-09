class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content

  validate :validate_beginning
  validates :type_of_discount, presence: true
  validates :discount_amount, presence: true
  validates :content, presence: true
end