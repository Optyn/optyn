class CouponMessage < Message
  has_extension :class_name => 'CouponMessageExtension', :foreign_key => :message_id,
    :attrs => [:redemption_instructions, :display_qr_code]

  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending, :permanent_coupon

  before_save :assign_coupon_code

  with_options on: :update do |m|
    m.validate :validate_ending
    m.validates :type_of_discount, presence: { message: 'Select the type of discount' }
    m.validate :validate_discount_amount
    m.validates :content, presence: true
  end

  def qr_code_link(receiver = nil)
    id = self.uuid
    id << "--#{receiver.uuid}" if receiver.present?
    "#{SiteConfig.email_app_base_url}#{SiteConfig.simple_delivery.qr_code_path}/#{id}.png"
  end

end