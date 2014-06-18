class EventMessage < Message
  attr_accessible :content, :ending, :rsvp

  with_options on: :update do |m|
    m.validates :content, presence: true
    m.validate :validate_ending
  end
end