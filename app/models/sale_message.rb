class SaleMessage < Message
  attr_accessible :content, :ending, :permanent_coupon

  with_options on: :update do |m|
    m.validates :content, presence: true
    m.validate :validate_ending
  end
end