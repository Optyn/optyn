class EventMessage < Message
  attr_accessible :content, :ending, :rsvp

  validates :content, presence: true
  validate :validate_ending
end