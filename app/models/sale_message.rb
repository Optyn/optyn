class SaleMessage < Message
  has_extension :class_name => 'SaleMessageExtension', :foreign_key => :message_id,
  	:attrs => [:redemption_instructions]

  attr_accessor :beginning_date, :beginning_time
  attr_accessible :content, :ending, :permanent_coupon, :fine_print, :beginning_date, :beginning_time, :beginning

  with_options on: :update do |m|
    m.validates :content, presence: true
    m.validate :validate_ending
    m.validate :validate_start_and_end_dates
  end
end