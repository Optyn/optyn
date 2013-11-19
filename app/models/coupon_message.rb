class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  validate :validate_ending
  validates :type_of_discount, presence: true
  validate :validate_discount_amount
  validates :content, presence: true
  validate :validate_ending

  def get_qr_code_link(current_user)
    url = "#{SiteConfig.app_base_url}/redeem/"

    current_user_id = current_user ? current_user.id : nil
    message_user = Encryptor.encrypt(self.id, current_user_id)
    url << message_user
    p url
    url
  end
  
  private
  def validate_discount_amount
    return self.errors.add(:discount_amount, "Please add the discount amount") if discount_amount.blank?
    numeric_amount = discount_amount.to_i

    if percentage_off?
      self.errors.add(:discount_amount, "Please add valid values between 0 - 100") if numeric_amount <= 0 || numeric_amount > 100
    else
      self.errors.add(:discount_amount, "Please make sure you add a numeric value") if numeric_amount <= 0
    end
  end
end