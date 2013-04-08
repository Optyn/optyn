class SpecialMessage < Message
  attr_accessible :content, :beginning, :fine_print

  validates :content, presence: true
  validate :validate_beginning
end