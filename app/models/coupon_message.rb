class CouponMessage < Message
  has_one :extension, :class_name => 'CouponMessageExtension', :foreign_key => :message_id

  attr_accessor :redemption_instructions

  attr_accessible :type_of_discount, :discount_amount, :fine_print, :coupon_code, :content, :ending,
    :permanent_coupon, :redemption_instructions

  after_initialize :load_extension
  before_save :assign_coupon_code, :save_extension
  before_destroy :destroy_extension

  with_options on: :update do |m|
    m.validate :validate_ending
    m.validates :type_of_discount, presence: true
    m.validate :validate_discount_amount
    m.validates :content, presence: true
    m.validate :validate_ending
  end

  default_scope { includes :extension }

  private

  def load_extension
    extension = self.extension || self.build_extension
    @redemption_instructions = extension.redemption_instructions
  end

  def save_extension
    extension = self.extension || self.build_extension
    extension.redemption_instructions = @redemption_instructions
    # Error management can be done here
    extension.save
  end

  def destroy_extension
    self.extension.destroy if self.extension.exists?
  end
end