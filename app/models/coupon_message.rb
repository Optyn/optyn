class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  before_save :assign_coupon_code

  with_options on: :update do |m|
    m.validate :validate_ending
    m.validates :type_of_discount, presence: true
    m.validate :validate_discount_amount
    m.validates :content, presence: true
    m.validate :validate_ending
  end
end