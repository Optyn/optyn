class EventMessage < Message
  attr_accessible :content, :beginning

  validates :content, presence: true
  validate :validate_beginning
end