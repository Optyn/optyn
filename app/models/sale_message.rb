class SaleMessage < Message
  has_extension :class_name => 'SaleMessageExtension', :foreign_key => :message_id,
  	:attrs => [:redemption_instructions]

  attr_accessible :content, :ending, :permanent_coupon, :fine_print

  with_options on: :update do |m|
    m.validates :content, presence: true
    m.validate :validate_ending
  end
end