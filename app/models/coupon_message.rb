class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print

  validates :content, presence: true
  validate :validate_beginning
end