class SaleMessage < Message
  attr_accessible :content, :ending

  validates :content, presence: true
  validate :validate_ending
end