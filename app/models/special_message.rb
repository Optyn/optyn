class SpecialMessage < Message
  has_extension :class_name => 'SpecialMessageExtension', :foreign_key => :message_id,
  	:attrs => [:redemption_instructions]
  
  attr_accessible :content, :type_of_discount, :discount_amount, :ending, :fine_print, :coupon_code, :permanent_coupon
  
  before_save :assign_coupon_code

  with_options on: :update do |m|
    m.validates :content, presence: true
    m.validates :type_of_discount, presence: true, if: :partner_eatstreet?
    m.validate :validate_discount_amount, if: :partner_eatstreet?
    m.validate :validate_ending
  end
end