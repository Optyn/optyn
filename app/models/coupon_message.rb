class CouponMessage < Message
  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  before_save :assign_coupon_code

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
end