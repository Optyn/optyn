class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  validate :validate_ending
  validates :type_of_discount, presence: true
  validate :validate_discount_amount
  validates :content, presence: true
  validate :validate_ending

  private
  def validate_discount_amount
    return self.errors.add(:base, "You need to add the discount amount") if discount_amount.blank?
    numeric_amount = discount_amount.to_i

    if percentage_off?
      self.errors.add(:base, "Please add valid values between 0 - 100") if numeric_amount <= 0 || numeric_amount > 100
    else
      self.errors.add(:base, "Please make sure you add a numeric value") if numeric_amount <= 0
    end
  end
end