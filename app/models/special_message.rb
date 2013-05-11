class SpecialMessage < Message
  attr_accessible :content, :ending, :fine_print

  validates :content, presence: true
  validate :validate_ending
end