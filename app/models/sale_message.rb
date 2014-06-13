class SaleMessage < Message
  attr_accessible :content, :ending, :permanent_coupon

  validates :content, presence: true
  validate :validate_ending
end